/***********************************************************************************************
Copyright  :  -- This confidential and proprietary software may be used
              -- only as authorized by a licensing agreement from
              -- Research Center for Mobile Computing (RCMC), Tsinghua University.
              -- (C) COPYRIGHT 2018 RCMC, Tsinghua University
              -- ALL RIGHTS RESERVED
              -- The entire notice above must be reproduced on all authorized copies.
File Name  :  pea_top_tb.v
Module Name:  tb_pea_top
Author     :  Gu Jiangyuan    
Version    :  1.0

Description:  test for pea_top
****************************************************************************************************/

`timescale 1 ns /1 ps
//`include "../pea_define.v"

module tb_pea_top;

    parameter pe_horizontal           	= 	8								;
    parameter pe_vertical             	= 	8								;
    parameter pe_total                	= 	pe_horizontal * pe_vertical		;
    parameter lsu_unit_num            	= 	64								;
    parameter pe_global_addr_width    	= 	`gr_addr_width_value			;
    parameter pe_local_addr_width     	= 	3								;
    parameter cache_conf_addr_width   	= 	32								;
    parameter cache_data_addr_width   	= 	32								;
    parameter cache_data_data_width   	= 	256								;
    parameter sm_bank_num             	= 	16								;
    parameter share_mem_addr_width    	= 	8								;
    parameter share_mem_data_width    	= 	32								;
    parameter config_addr_width       	= 	6								;
    parameter config_data_width       	= 	64								;
    parameter comput_data_width       	= 	32								;	
	parameter data_read_data_length		= 	40								;		//data read length
	parameter config_read_data_length	= 	15								;		//config read length	
	
	reg						 			 			clk							;
	reg 						 					rst							;
																						
    reg 											pe_cpu_start            	;
    reg 											pea_cpu_start           	;	
    wire	[pe_total-1:0]                  		pea_ready 					;
    wire	[pe_total-1:0]                  		pe_ready  					;
    wire	[pe_total-1:0]                  		pe_config_empty 			;
    wire	[pe_total-1:0]                  		pe_config_full  			;
				
    reg                                   			pea_global_en_w   			;
    reg   	[pe_global_addr_width-1:0]    			pea_global_addr   			;  
    reg   	[comput_data_width-1:0]       			pea_global_din_w  			; 
    wire  	[comput_data_width-1:0]       			pea_global_dout_r 			;
								
    reg	                                   			pea_conf_start          	;
    reg	                                   			pea_conf_addr_base_en   	;  
    reg	                                   			pea_conf_addr_len_en    	; 
    reg	  	[cache_conf_addr_width-1:0]     		pea_conf_addr_base      	;  
    reg	  	[cache_conf_addr_width-1:0]     		pea_conf_addr_len       	;
						
    reg                                   			pea_conf_addr_in_ready 		;
    wire  	[config_data_width-1:0]         		config_mem_w_data       	;
    wire                                   			config_mem_w_data_en    	;	
    wire                                  			pea_conf_addr_r_en      	; 
    wire 	[cache_conf_addr_width-1:0]     		pea_conf_addr_r         	;       
    wire                                  			pea_config_finish       	; 
						
    reg                                   			pea_data_start          	;
    reg                                   			pea_data_addr_base_en   	;  
    reg                                   			pea_data_addr_len_en    	;  
    reg 	[cache_data_addr_width-1:0]     		pea_data_addr_base      	;  
    reg 	[cache_data_addr_width-1:0]     		pea_data_addr_len       	;
				
    reg                                   			pea_data_addr_in_ready 		;	
    wire	[cache_data_data_width-1:0]     		cache_sm_w_data         	;
    wire                                   			cache_sm_w_data_en      	;	
    wire                                  			pea_data_addr_r_en      	; 
    wire	[cache_data_addr_width-1:0]     		pea_data_addr_r         	;      
    wire                                  			pea_sm_data_finish      	;                       
			
//	reg                                   			dma2pea_addr_en          	;
    reg                                   			dma2pea_addr_r_en        	;
    reg                                   			dma2pea_addr_w_en        	;
    reg 	[share_mem_data_width-1:0]      		dma2pea_data_w           	;
    reg 	[cache_data_addr_width-1:0]     		dma2pea_addr             	;
    wire	[share_mem_data_width-1:0]      		pea2dma_data_r           	;
    wire                                  			pea2dma_data_r_en        	;

	
    reg 	[comput_data_width*lsu_unit_num-1:0] 	pea_sm_data_r_in       		; 	//other Pea_ShareMemory
    reg 	[lsu_unit_num-1:0]                   	pea_sm_data_r_in_en    		; 	//other Pea_ShareMemory    
    wire	[(share_mem_addr_width+5)*lsu_unit_num-1:0] 	local_sm_addr          		;
    wire	[comput_data_width*lsu_unit_num-1:0] 	local_sm_data_w        		;
    wire	[lsu_unit_num-1:0]                   	local_sm_data_w_en     		;
    wire	[lsu_unit_num-1:0]                   	local_sm_data_r_en     		;

    reg		[(share_mem_addr_width+5)*lsu_unit_num-1:0] 	pea_sm_addr         		;
    reg		[comput_data_width*lsu_unit_num-1:0] 	pea_sm_data_w       		;
    reg		[lsu_unit_num-1:0]                   	pea_sm_data_w_en    		;
    reg		[lsu_unit_num-1:0]                   	pea_sm_data_r_en    		;
    wire	[comput_data_width*lsu_unit_num-1:0] 	local_sm_data_r_out       	;  
    wire	[lsu_unit_num-1:0]                   	local_sm_data_r_out_en    	;

	
    reg                                       		debug_input_clear        	;
    reg                                       		debug_input_en           	;
    reg  	[8:0]                                	debug_input_pe_index     	;
    reg  	[31:0]                               	debug_input_info 		 	;
    wire                                      		debug_output_en          	;
    wire 	[comput_data_width-1:0]              	debug_output_data        	;
    wire 	[config_data_width-1:0]              	debug_output_config      	;
	

	
	/******************************** generate the clock and reset signal *******************************/
	initial 
		begin
				clk 	= 	'b1		;			
				rst 	= 	'b1		;
			#3 	rst 	=	'b0		;
			#5 	rst 	=	'b1		;			
		end
		
	always
		begin
			#5	clk 	= 	~clk	;
		end
		
		
	initial 
		begin
			//package1
			#5
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			

				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'b0		;
				pea_conf_addr_len           =	'b0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				                        
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'b0		;
				pea_data_addr_len           =	'b0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;
			
			// set base addr to read data and config from cache
			#10	
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b1		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b1		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;		

			// set length to read data and config from cache
			#10	
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b1		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd592		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b1		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd512	;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;	
				
			// start to read data and config from cache
			#10	
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b1		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b1		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;					

			// clear to read data and config from cache
			#10	
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;

			// begin to compute the first cp package for iteration = 0
			#6000	
				pe_cpu_start            	=	'b1		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;	

			#10	
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;


			// package 2
			// set base addr to read data and config from cache
			#2000					
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			

				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'b0		;
				pea_conf_addr_len           =	'b0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				                        
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'b0		;
				pea_data_addr_len           =	'b0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;

			#10
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b1		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd592		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b1		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;		

			// set length to read data and config from cache
			#10	
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b1		;
				pea_conf_addr_base          =	'd592		;
				pea_conf_addr_len           =	'd48		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b1		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd512	;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;	
				
			// start to read data and config from cache
			#10	
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b1		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b1		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;					

			// clear to read data and config from cache
			#10	
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;
			
			// begin to compute the first cp package for iteration = 0
			#1000	
				pe_cpu_start            	=	'b1		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;	

			#10	
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;	

			//package3
				// set base addr to read data and config from cache
			#2000					
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			

				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'b0		;
				pea_conf_addr_len           =	'b0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				                        
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'b0		;
				pea_data_addr_len           =	'b0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;

			#10
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b1		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd640		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b1		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;		

			// set length to read data and config from cache
			#10	
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b1		;
				pea_conf_addr_base          =	'd640		;
				pea_conf_addr_len           =	'd36		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b1		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd512	;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;	
				
			// start to read data and config from cache
			#10	
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b1		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b1		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;					

			// clear to read data and config from cache
			#10	
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;
			
			// begin to compute the first cp package for iteration = 0
			#1000	
				pe_cpu_start            	=	'b1		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;	

			#10	
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;	

			// begin to compute the first cp package for iteration = 1
			/*#800	
				pe_cpu_start            	=	'b1		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;	

			#10	
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;	

			// begin to compute the first cp package for iteration = 2
			#800	
				pe_cpu_start            	=	'b1		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;	

			#10	
				pe_cpu_start            	=	'b0		;
				pea_cpu_start           	=	'b0		;		 					
							            
				pea_global_en_w   			=	'b0		;		
				pea_global_addr   			=	'b0		;		
				pea_global_din_w  			=	'b0		;			
				
				// begin read config
				pea_conf_start              =	'b0		;
				pea_conf_addr_base_en       =	'b0		;
				pea_conf_addr_len_en        =	'b0		;
				pea_conf_addr_base          =	'd0		;
				pea_conf_addr_len           =	'd0		;
				                     
				pea_conf_addr_in_ready 	    =	'b1		;  
				
				// begin read data
				pea_data_start              =	'b0		;
				pea_data_addr_base_en       =	'b0		;
				pea_data_addr_len_en        =	'b0		;
				pea_data_addr_base          =	'd0		;
				pea_data_addr_len           =	'd0		;
							               
				pea_data_addr_in_ready 		=	'b1		;		
    						               		
				dma2pea_addr_r_en       	=	'b0		;		
				dma2pea_addr_w_en       	=	'b0		;		
				dma2pea_data_w          	=	'b0		;		
				dma2pea_addr            	=	'b0		;		      										
							            
				pea_sm_data_r_in       		=	'b0		;		
				pea_sm_data_r_in_en    		=	'b0		;		   	
				                          
				pea_sm_addr         	    =	'b0		;
				pea_sm_data_w       	    =	'b0		;
				pea_sm_data_w_en    	    =	'b0		;
				pea_sm_data_r_en    		=	'b0		;		
				                           
				debug_input_clear           =	'b0		;
				debug_input_en              =	'b0		;
				debug_input_pe_index        =	'b0		;
				debug_input_info 	   	    =	'b0		;*/
				
	
				
				
		end
		

	/********************************** instantialize the pe_top module **********************************/
	pea_top  u0_pea_top
	(
		.pea_ready				(pea_ready				)	,
		.pe_ready				(pe_ready				)	,
		.pe_config_empty		(pe_config_empty		)	,
		.pe_config_full			(pe_config_full			)	,
		.pea_global_dout_r		(pea_global_dout_r		)	,
		.pea_conf_addr_r_en		(pea_conf_addr_r_en		)	,
		.pea_conf_addr_r		(pea_conf_addr_r		)	,
		.pea_config_finish		(pea_config_finish		)	,
		.pea_data_addr_r_en		(pea_data_addr_r_en		)	,
		.pea_data_addr_r		(pea_data_addr_r		)	,
		.pea_sm_data_finish		(pea_sm_data_finish		)	,
		.pea2dma_data_r			(pea2dma_data_r			)	,
		.pea2dma_data_r_en		(pea2dma_data_r_en		)	,
		.local_sm_addr			(local_sm_addr			)	,
		.local_sm_data_w		(local_sm_data_w		)	,
		.local_sm_data_w_en		(local_sm_data_w_en		)	,
		.local_sm_data_r_en		(local_sm_data_r_en		)	,
		.local_sm_data_r_out	(local_sm_data_r_out	)	,
		.local_sm_data_r_out_en	(local_sm_data_r_out_en	)	,
		.debug_output_en		(debug_output_en		)	,
		.debug_output_data		(debug_output_data		)	,
		.debug_output_config	(debug_output_config	)	,
	                             
		.clk					(clk					)	,
		.rst_n					(rst					)	,
		.pe_cpu_start			(pe_cpu_start			)	,
		.pea_cpu_start			(pea_cpu_start			)	,
		.pea_global_en_w		(pea_global_en_w		)	,
		.pea_global_addr		(pea_global_addr		)	,
		.pea_global_din_w		(pea_global_din_w		)	,
		.pea_conf_start			(pea_conf_start			)	,
		.pea_conf_addr_base_en	(pea_conf_addr_base_en	)	,
		.pea_conf_addr_len_en	(pea_conf_addr_len_en	)	,
		.pea_conf_addr_base		(pea_conf_addr_base		)	,
		.pea_conf_addr_len		(pea_conf_addr_len		)	,
		.pea_conf_addr_in_ready	(pea_conf_addr_in_ready	)	,
		.config_mem_w_data		(config_mem_w_data		)	,
		.config_mem_w_data_en	(config_mem_w_data_en	)	,
		.pea_data_start			(pea_data_start			)	,
		.pea_data_addr_base_en	(pea_data_addr_base_en	)	,
		.pea_data_addr_len_en	(pea_data_addr_len_en	)	,
		.pea_data_addr_base		(pea_data_addr_base		)	,
		.pea_data_addr_len		(pea_data_addr_len		)	,
		.pea_data_addr_in_ready	(pea_data_addr_in_ready	)	,
		.cache_sm_w_data		(cache_sm_w_data		)	,
		.cache_sm_w_data_en		(cache_sm_w_data_en		)	,
		.dma2pea_addr_r_en		(dma2pea_addr_r_en		)	,
		.dma2pea_addr_w_en		(dma2pea_addr_w_en		)	,
		.dma2pea_data_w			(dma2pea_data_w			)	,
		.dma2pea_addr			(dma2pea_addr			)	,
		.pea_sm_data_r_in		(pea_sm_data_r_in		)	,
		.pea_sm_data_r_in_en	(pea_sm_data_r_in_en	)	,
		.pea_sm_addr			(pea_sm_addr			)	,
		.pea_sm_data_w			(pea_sm_data_w			)	,
		.pea_sm_data_w_en		(pea_sm_data_w_en		)	,
		.pea_sm_data_r_en		(pea_sm_data_r_en		)	,
		.debug_input_en			(debug_input_en			)	,
		.debug_input_pe_index	(debug_input_pe_index	)	,
		.debug_input_info		(debug_input_info		)	,
		.debug_input_clear      (debug_input_clear      )
	);

	
 	/********************************** instantialize the pea data memory **********************************/
	wire									d_mem_en				;		
	wire									d_rd_wr					;		
	wire	[cache_conf_addr_width - 1:0]	d_addr					;		
	wire	[cache_data_data_width-1:0]		d_data_in				;	
	wire	[cache_data_data_width-1:0]		d_data_out				;
	reg										reg_cache_sm_w_data_en	;
	
	assign	d_mem_en				=		~pea_data_addr_r_en 	;
	assign	d_rd_wr					=		pea_data_addr_r_en   	;
	assign	d_addr					=		pea_data_addr_r		    ;
    assign	d_data_in				=		'b0						;
    assign	cache_sm_w_data			=		d_data_out				;
	assign	cache_sm_w_data_en		= 		reg_cache_sm_w_data_en	;

	always @(posedge clk or negedge rst)
		begin
			if (~rst)
				begin
					reg_cache_sm_w_data_en		<=	'b0						;
				end
			else 
				begin
					reg_cache_sm_w_data_en		<=	pea_data_addr_r_en		;
				end
		end	
		
	pea_data_memory #(
					  .read_data_length(data_read_data_length)
					)
					u0_pea_data_memory
	( 
		.rst		(rst			)	, 
		.clk		(clk			)	, 
		.mem_en		(d_mem_en		)	, 
		.rd_wr		(d_rd_wr		)	, 
		.addr		(d_addr			)	, 
		.data_in	(d_data_in		)	, 
		.data_out	(d_data_out		)
	);
  
	/********************************** instantialize the pea config memory **********************************/ 
	wire									c_mem_en					;		
	wire									c_rd_wr						;		
	wire	[cache_conf_addr_width - 1:0]	c_addr						;		
	wire	[config_data_width-1:0]			c_data_in					;	
	wire	[config_data_width-1:0]			c_data_out					;
	reg										reg_config_mem_w_data_en	;

	assign	c_mem_en					=	~pea_conf_addr_r_en			;
	assign	c_rd_wr						=	pea_conf_addr_r_en   		;
	assign	c_addr						=	pea_conf_addr_r				;
    assign	c_data_in					=	'b0							;
    assign	config_mem_w_data			=	c_data_out					;
	assign	config_mem_w_data_en		=	reg_config_mem_w_data_en	;
	
	always @(posedge clk or negedge rst)
		begin
			if (~rst)
				begin
					reg_config_mem_w_data_en		<=	'b0						;
				end
			else 
				begin
					reg_config_mem_w_data_en		<=	pea_conf_addr_r_en		;
				end
		end		
	
	pea_config_memory #(
						.read_data_length(config_read_data_length)
					  )
					  u0_pea_config_memory 
	( 
		.rst		(rst			)	, 
		.clk		(clk			)	, 
		.mem_en		(c_mem_en		)	, 
		.rd_wr		(c_rd_wr		)	, 
		.addr		(c_addr			)	, 
		.data_in	(c_data_in		)	, 
		.data_out	(c_data_out		)
	);


    initial 
		begin
         		#16000
        		$finish	;
     		end


    // dump wave
    initial 
		begin
         		$fsdbDumpfile("tb_pea_top.fsdb");
        		$fsdbDumpvars();
     		end	
  
  
endmodule





