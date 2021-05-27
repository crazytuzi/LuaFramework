------------------------------------------------------
--特效配置，与粒子系统结合使用

-- emit_offest_area 发射区域在世界所处的位置,
-- （注：x,y偏移屏幕左上角。w往右区域，h为负时为往下区域)
-- emit_start_time 开始发射时间
-- emit_frequency 发射器发射频率
-- emit_num_dynamic 发射器在同一时间发射随机数动态分布 最大数，最低几率，最高几率
-- emit_keep_time 发射器发射持续时间
-- emit_rotation 发射器发射角度
-- max_num_in_rect 区域最大数

-- p_move_type 粒子运动方式
-- p_move_param 粒子运动方式参数
-- p_move_speed 粒子移动速度
-- p_rotation_speed 粒子角度旋转速度

--@author bzw
------------------------------------------------------

--送一朵花特效
Effect_One_Flower = 
{
	name = "one_flower",	
	pingbi = 1,									
	emit_list = {				
		[1] = {                                   			
				emit_offest_area = {nil, 0, nil, -150},		
				emit_start_time = 0,                        
				emit_frequency = 0.5,						
				emit_num_dynamic = {2, 50, 100}, 			
				emit_keep_time = 12,						
				emit_rotation = 30,							
				max_num_in_rect = 200,						

				seed_list = {								
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_6.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_7.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_8.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_9.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_10.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_11.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_12.png", scale = 1, power = 5},
							},		

				p_move_type = "sinx_line",					
				p_move_param = {param1 = 1, param2 = 30},	
				p_move_speed = -1,							
				p_rotation_speed = 0,						
			  },


		[2] = {                                  		 	
			emit_offest_area = nil,							
			emit_start_time = 0,                         	
			emit_frequency = 2,								
			emit_num_dynamic = {3, 50, 100}, 				
			emit_keep_time = 20,							
			emit_rotation = 0,								
			max_num_in_rect = 20,							

			seed_list = {									
							{seed_type="animation", seed_id = 3056, scale = 1, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.2, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.4, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.6, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.8, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 2, power = 1},
							-- {seed_type="animation", seed_id = 3057, power = 1},
						},			

			p_move_type = nil,								
			p_move_area = nil,								
			p_move_speed = 0,								
			p_rotation_speed = 0,							
		  },
		
	}
}

--送红色花特效
Effect_Red_Flower = 
{
	name = "red_flower",	
	pingbi = 1,									
	emit_list = {			
		[1] = {                                     			
				emit_offest_area = {nil, 0, nil, -120},			
				emit_start_time = 0,                          	
				emit_frequency = 3,								
				emit_num_dynamic = {3, 50, 100}, 				
				emit_keep_time = 15,							
				emit_rotation = 0,								
				max_num_in_rect = 20,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_1.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_2.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_3.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_4.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_5.png", scale = 1, power = 5},
							},			

				p_move_type = "sinx_line",						
				p_move_param = {param1 = 0.2, param2 = 6},		
				p_move_speed = -0.6,							
				p_rotation_speed = 0,							
			  },
			  
		[2] = {                                     			
				emit_offest_area = {nil, 0, nil, -120},			
				emit_start_time = 1.5,                          
				emit_frequency = 3,								
				emit_num_dynamic = {3, 50, 100}, 				
				emit_keep_time = 15,							
				emit_rotation = 0,								
				max_num_in_rect = 20,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_1.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_2.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_3.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_4.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_5.png", scale = 1, power = 5},
							},		

				p_move_type = "sinx_line",						
				p_move_param = {param1 = 0.2, param2 = 8},		
				p_move_speed = -0.8,							
				p_rotation_speed = 0,							
			  },
		
		[3] = {                                    				
				emit_offest_area = {nil, 0, nil, -10},			
				emit_start_time = 0,                           
				emit_frequency = 0.2,							
				emit_num_dynamic = {2, 50, 100}, 				
				emit_keep_time = 15,							
				emit_rotation = 0,								
				max_num_in_rect = 500,							

				seed_list = {								
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_6.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_7.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_8.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_9.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_10.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_11.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_12.png", scale = 1, power = 5},
							},			

				p_move_type = "sinx_line",					
				p_move_param = {param1 = 1, param2 = 20},	
				p_move_speed = -1,							
				p_rotation_speed = 0,						
			  },
		
		[4] = {                                   			
				emit_offest_area = {nil, 0, 512, -150},		
				emit_start_time = 0,                        
				emit_frequency = 0.5,						
				emit_num_dynamic = {2, 50, 100}, 			
				emit_keep_time = 15,						
				emit_rotation = 0,							
				max_num_in_rect = 200,						

				seed_list = {								
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_6.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_7.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_8.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_9.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_10.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_11.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_12.png", scale = 1, power = 5},
							},		

				p_move_type = "sinx_line",					
				p_move_param = {param1 = 1, param2 = 30},	
				p_move_speed = -1,							
				p_rotation_speed = 0,						
			  },


		[5] = {                                  		 	
			emit_offest_area = nil,							
			emit_start_time = 0,                         	
			emit_frequency = 2,								
			emit_num_dynamic = {3, 50, 100}, 				
			emit_keep_time = 20,							
			emit_rotation = 0,								
			max_num_in_rect = 20,							

			seed_list = {									
							{seed_type="animation", seed_id = 3056, scale = 1, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.2, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.4, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.6, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.8, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 2, power = 1},
							-- {seed_type="animation", seed_id = 3057, power = 1},
						},			

			p_move_type = nil,								
			p_move_area = nil,								
			p_move_speed = 0,								
			p_rotation_speed = 0,							
		  },
		  
		[6] = {                                     		
			emit_offest_area = nil,							
			emit_start_time = 0.5,                         
			emit_frequency = 2,								
			emit_num_dynamic = {3, 50, 100}, 				
			emit_keep_time = 20,							
			emit_rotation = 0,								
			max_num_in_rect = 20,							

			seed_list = {									
							{seed_type="animation", seed_id = 3056, scale = 1, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.2, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.4, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.6, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.8, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 2, power = 1},
							-- {seed_type="animation", seed_id = 3057, power = 1},
						},			

			p_move_type = nil,								
			p_move_area = nil,								
			p_move_speed = 0,								
			p_rotation_speed = 0,							
		  },
		  
		[7] = {                                     		
			emit_offest_area = nil,							
			emit_start_time = 1.5,                         
			emit_frequency = 2,								
			emit_num_dynamic = {4, 50, 100}, 				
			emit_keep_time = 20,							
			emit_rotation = 0,								
			max_num_in_rect = 20,							

			seed_list = {									
							{seed_type="animation", seed_id = 3056, scale = 1, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.2, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.4, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.6, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.8, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 2, power = 1},
							-- {seed_type="animation", seed_id = 3057, power = 1},
						},			

			p_move_type = nil,								
			p_move_area = nil,								
			p_move_speed = 0,								
			p_rotation_speed = 0,							
		  },
		
	}
}

--送蓝色花特效
Effect_Blue_Flower = 
{
	name = "blue_flower",
	pingbi = 1,							
	emit_list = {
		[1] = {                                     
				emit_offest_area = {nil, 0, nil, -120},		
				emit_start_time = 0,                         
				emit_frequency = 3,							
				emit_num_dynamic = {3, 50, 100}, 			
				emit_keep_time = 15,						
				emit_rotation = 0,							
				max_num_in_rect = 20,						

				seed_list = {								
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_1.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_2.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_3.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_4.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_5.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_1.png", scale = 0.8, power = 2},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_2.png", scale = 0.8, power = 2},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_3.png", scale = 0.8, power = 2},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_4.png", scale = 0.8, power = 2},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_5.png", scale = 0.8, power = 2},
							},			

				p_move_type = "sinx_line",						
				p_move_param = {param1 = 0.2, param2 = 6},		
				p_move_speed = -0.6,							
				p_rotation_speed = 0,							
			  },
			  
		[2] = {                                     
				emit_offest_area = {nil, 0, nil, -120},			
				emit_start_time = 1.5,                         
				emit_frequency = 3,								
				emit_num_dynamic = {3, 50, 100}, 				
				emit_keep_time = 15,							
				emit_rotation = 0,								
				max_num_in_rect = 20,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_1.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_2.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_3.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_4.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_5.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_1.png", scale = 0.8, power = 2},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_2.png", scale = 0.8, power = 2},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_3.png", scale = 0.8, power = 2},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_4.png", scale = 0.8, power = 2},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_5.png", scale = 0.8, power = 2},
							},		

				p_move_type = "sinx_line",						
				p_move_param = {param1 = 0.2, param2 = 8},		
				p_move_speed = -0.8,							
				p_rotation_speed = 0,							
			  },
		
		[3] = {                                    
				emit_offest_area = {nil, 0, nil, -10},			
				emit_start_time = 0,                           
				emit_frequency = 0.2,							
				emit_num_dynamic = {2, 50, 100}, 				
				emit_keep_time = 15,							
				emit_rotation = 0,								
				max_num_in_rect = 500,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_6.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_7.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_8.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_9.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_10.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_11.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_12.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_6.png", scale = 0.5, power = 1},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_7.png", scale = 0.5, power = 1},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_8.png", scale = 0.5, power = 1},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_9.png", scale = 0.5, power = 1},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_10.png", scale = 0.5, power = 1},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_11.png", scale = 0.5, power = 1},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_12.png", scale = 0.5, power = 1},
							},			

				p_move_type = "sinx_line",					
				p_move_param = {param1 = 1, param2 = 20},	
				p_move_speed = -1,							
				p_rotation_speed = 0,						
			  },
		
		[4] = {                                    
				emit_offest_area = {nil, 0, 512, -150},		
				emit_start_time = 0,                       
				emit_frequency = 0.5,						
				emit_num_dynamic = {2, 50, 100}, 			
				emit_keep_time = 15,						
				emit_rotation = 0,							
				max_num_in_rect = 200,						

				seed_list = {								
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_6.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_7.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_8.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_9.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_10.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_11.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_red_12.png", scale = 1, power = 5},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_6.png", scale = 0.5, power = 1},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_7.png", scale = 0.5, power = 1},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_8.png", scale = 0.5, power = 1},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_9.png", scale = 0.5, power = 1},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_10.png", scale = 0.5, power = 1},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_11.png", scale = 0.5, power = 1},
								{seed_type="texture", seed_path = "res/xui/ps/flower_blue_12.png", scale = 0.5, power = 1},
							},			

				p_move_type = "sinx_line",					
				p_move_param = {param1 = 1, param2 = 30},	
				p_move_speed = -1,							
				p_rotation_speed = 0,						
			  },


		[5] = {                                  		 	
			emit_offest_area = nil,							
			emit_start_time = 0,                         	
			emit_frequency = 2,								
			emit_num_dynamic = {3, 50, 100}, 				
			emit_keep_time = 20,							
			emit_rotation = 0,								
			max_num_in_rect = 20,							

			seed_list = {									
							{seed_type="animation", seed_id = 3056, scale = 1, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.2, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.4, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.6, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.8, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 2, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 1, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 1.2, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 1.4, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 1.6, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 1.8, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 2, power = 1},
							
						},			

			p_move_type = nil,								
			p_move_area = nil,								
			p_move_speed = 0,								
			p_rotation_speed = 0,							
		  },
		  
		[6] = {                                     		
			emit_offest_area = nil,							
			emit_start_time = 0.5,                         
			emit_frequency = 2,								
			emit_num_dynamic = {3, 50, 100}, 				
			emit_keep_time = 20,							
			emit_rotation = 0,								
			max_num_in_rect = 20,							

			seed_list = {									
							{seed_type="animation", seed_id = 3056, scale = 1, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.2, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.4, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.6, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.8, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 2, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 1, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 1.2, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 1.4, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 1.6, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 1.8, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 2, power = 1},
						},			

			p_move_type = nil,								
			p_move_area = nil,								
			p_move_speed = 0,								
			p_rotation_speed = 0,							
		  },
		  
		[7] = {                                     		
			emit_offest_area = nil,	
			emit_start_time = 1.5,                         
			emit_frequency = 2,								
			emit_num_dynamic = {4, 50, 100}, 			
			emit_keep_time = 20,							
			emit_rotation = 0,								
			max_num_in_rect = 20,							

			seed_list = {									
							{seed_type="animation", seed_id = 3056, scale = 1, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.2, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.4, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.6, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 1.8, power = 1},
							{seed_type="animation", seed_id = 3056, scale = 2, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 1, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 1.2, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 1.4, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 1.6, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 1.8, power = 1},
							{seed_type="animation", seed_id = 3057, scale = 2, power = 1},
						},			

			p_move_type = nil,								
			p_move_area = nil,								
			p_move_speed = 0,								
			p_rotation_speed = 0,							
		  },

	}
}

--TIPS紫色星星特效
Star_Flash_3 = 
{
	name = "star_flash_3",		
	pingbi = 0,								
	emit_list = {

		[1] = {                                     			
				emit_offest_area = {20, -25, 310, -30},			
				emit_start_time = 0,                          	
				emit_frequency = 2,								
				emit_num_dynamic = {6, 100, 100}, 				
				emit_keep_time = 1,							
				emit_rotation = 0,								
				max_num_in_rect = 8,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/star_flash_3.png", scale = 0.1, power = 5,opacity = 0},
							},			

				p_move_type = nil,						
				p_move_param = nil,		
				p_move_speed = 0,							
				p_rotation_speed = 0,
				p_act_list = {"star_flash1","star_flash2","star_flash3","star_flash4","star_flash5","star_flash6","star_flash7","star_flash8"},							
			  },

		[2] = {                                     			
				emit_offest_area = {20, -65, 100, -90},			
				emit_start_time = 0,                          	
				emit_frequency = 2,								
				emit_num_dynamic = {3, 100, 100}, 				
				emit_keep_time = 1,							
				emit_rotation = 0,								
				max_num_in_rect = 4,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/star_flash_3.png", scale = 0.1, power = 5,opacity = 0},
							},			

				p_move_type = nil,						
				p_move_param = nil,		
				p_move_speed = 0,							
				p_rotation_speed = 0,
				p_act_list = {"star_flash1","star_flash2","star_flash3","star_flash4","star_flash5","star_flash6","star_flash7","star_flash8"},							
			  },

		[3] = {                                     			
				emit_offest_area = {120, -65, 210, -90},			
				emit_start_time = 0,                          	
				emit_frequency = 2,								
				emit_num_dynamic = {8, 100, 100}, 				
				emit_keep_time = 1,							
				emit_rotation = 0,								
				max_num_in_rect = 6,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/star_flash_3.png", scale = 0.1, power = 5,opacity = 0},
							},			

				p_move_type = nil,						
				p_move_param = nil,		
				p_move_speed = 0,							
				p_rotation_speed = 0,
				p_act_list = {"star_flash1","star_flash2","star_flash3","star_flash4","star_flash5","star_flash6","star_flash7","star_flash8"},							
			  },

		[4] = {                                     			
				emit_offest_area = {330, -65, 30, -90},			
				emit_start_time = 0,                          	
				emit_frequency = 2,								
				emit_num_dynamic = {1, 100, 100}, 				
				emit_keep_time = 1,							
				emit_rotation = 0,								
				max_num_in_rect = 2,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/star_flash_3.png", scale = 0.1, power = 5,opacity = 0},
							},			

				p_move_type = nil,						
				p_move_param = nil,		
				p_move_speed = 0,							
				p_rotation_speed = 0,
				p_act_list = {"star_flash1","star_flash2","star_flash3","star_flash4","star_flash5","star_flash6","star_flash7","star_flash8"},							
			  },


		
	}
}	

--TIPS橙色星星特效
Star_Flash_4 = 
{
	name = "star_flash_4",	
	pingbi = 0,										
	emit_list = {			
		[1] = {                                     			
				emit_offest_area = {20, -30, 310, -40},			
				emit_start_time = 0,                          	
				emit_frequency = 2,								
				emit_num_dynamic = {6, 100, 100}, 				
				emit_keep_time = 1,							
				emit_rotation = 0,								
				max_num_in_rect = 8,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/star_flash_4.png", scale = 0.1, power = 5,opacity = 0},
							},			

				p_move_type = nil,						
				p_move_param = nil,		
				p_move_speed = 0,							
				p_rotation_speed = 0,
				p_act_list = {"star_flash1","star_flash2","star_flash3","star_flash4","star_flash5","star_flash6","star_flash7","star_flash8"},							
			  },

		[2] = {                                     			
				emit_offest_area = {20, -70, 100, -90},			
				emit_start_time = 0,                          	
				emit_frequency = 2,								
				emit_num_dynamic = {3, 100, 100}, 				
				emit_keep_time = 1,							
				emit_rotation = 0,								
				max_num_in_rect = 4,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/star_flash_4.png", scale = 0.1, power = 5,opacity = 0},
							},			

				p_move_type = nil,						
				p_move_param = nil,		
				p_move_speed = 0,							
				p_rotation_speed = 0,
				p_act_list = {"star_flash1","star_flash2","star_flash3","star_flash4","star_flash5","star_flash6","star_flash7","star_flash8"},							
			  },

		[3] = {                                     			
				emit_offest_area = {120, -70, 210, -90},			
				emit_start_time = 0,                          	
				emit_frequency = 2,								
				emit_num_dynamic = {5, 100, 100}, 				
				emit_keep_time = 1,							
				emit_rotation = 0,								
				max_num_in_rect = 6,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/star_flash_4.png", scale = 0.1, power = 5,opacity = 0},
							},			

				p_move_type = nil,						
				p_move_param = nil,		
				p_move_speed = 0,							
				p_rotation_speed = 0,
				p_act_list = {"star_flash1","star_flash2","star_flash3","star_flash4","star_flash5","star_flash6","star_flash7","star_flash8"},							
			  },

		[4] = {                                     			
				emit_offest_area = {330, -70, 30, -90},			
				emit_start_time = 0,                          	
				emit_frequency = 2,								
				emit_num_dynamic = {1, 100, 100}, 				
				emit_keep_time = 1,							
				emit_rotation = 0,								
				max_num_in_rect = 2,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/star_flash_4.png", scale = 0.1, power = 5,opacity = 0},
							},			

				p_move_type = nil,						
				p_move_param = nil,		
				p_move_speed = 0,							
				p_rotation_speed = 0,
				p_act_list = {"star_flash1","star_flash2","star_flash3","star_flash4","star_flash5","star_flash6","star_flash7","star_flash8"},							
			  },


		
	}
}

--TIPS红色星星特效
Star_Flash_5 = 
{
	name = "star_flash_5",		
	pingbi = 0,									
	emit_list = {			
		[1] = {                                     			
				emit_offest_area = {20, -30, 310, -40},			
				emit_start_time = 0,                          	
				emit_frequency = 2,								
				emit_num_dynamic = {6, 100, 100}, 				
				emit_keep_time = 1,							
				emit_rotation = 0,								
				max_num_in_rect = 8,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/star_flash_5.png", scale = 0.1, power = 5,opacity = 0},
							},			

				p_move_type = nil,						
				p_move_param = nil,		
				p_move_speed = 0,							
				p_rotation_speed = 0,
				p_act_list = {"star_flash1","star_flash2","star_flash3","star_flash4","star_flash5","star_flash6","star_flash7","star_flash8"},							
			  },

		[2] = {                                     			
				emit_offest_area = {20, -70, 100, -90},			
				emit_start_time = 0,                          	
				emit_frequency = 2,								
				emit_num_dynamic = {3, 100, 100}, 				
				emit_keep_time = 1,							
				emit_rotation = 0,								
				max_num_in_rect = 4,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/star_flash_5.png", scale = 0.1, power = 5,opacity = 0},
							},			

				p_move_type = nil,						
				p_move_param = nil,		
				p_move_speed = 0,							
				p_rotation_speed = 0,
				p_act_list = {"star_flash1","star_flash2","star_flash3","star_flash4","star_flash5","star_flash6","star_flash7","star_flash8"},							
			  },

		[3] = {                                     			
				emit_offest_area = {120, -70, 210, -90},			
				emit_start_time = 0,                          	
				emit_frequency = 2,								
				emit_num_dynamic = {5, 100, 100}, 				
				emit_keep_time = 1,							
				emit_rotation = 0,								
				max_num_in_rect = 6,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/star_flash_5.png", scale = 0.1, power = 5,opacity = 0},
							},			

				p_move_type = nil,						
				p_move_param = nil,		
				p_move_speed = 0,							
				p_rotation_speed = 0,
				p_act_list = {"star_flash1","star_flash2","star_flash3","star_flash4","star_flash5","star_flash6","star_flash7","star_flash8"},							
			  },

		[4] = {                                     			
				emit_offest_area = {330, -70, 30, -90},			
				emit_start_time = 0,                          	
				emit_frequency = 2,								
				emit_num_dynamic = {1, 100, 100}, 				
				emit_keep_time = 1,							
				emit_rotation = 0,								
				max_num_in_rect = 2,							

				seed_list = {									
								{seed_type="texture", seed_path = "res/xui/ps/star_flash_5.png", scale = 0.1, power = 5,opacity = 0},
							},			

				p_move_type = nil,						
				p_move_param = nil,		
				p_move_speed = 0,							
				p_rotation_speed = 0,
				p_act_list = {"star_flash1","star_flash2","star_flash3","star_flash4","star_flash5","star_flash6","star_flash7","star_flash8"},							
			  },
	}
}	