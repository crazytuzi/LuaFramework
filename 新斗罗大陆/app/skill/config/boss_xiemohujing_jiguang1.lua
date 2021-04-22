local boss_xiemohujing_jiguang1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		     {
			     CLASS = "action.QSBApplyBuff",
			     OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		     },
		     {
			     CLASS = "composite.QSBSequence",
			     ARGS = {
				---
				          {
							CLASS = "composite.QSBParallel",
							ARGS = {
								     {
									     CLASS = "action.QSBActorStand",
								     },
								     {
									     CLASS = "action.QSBActorFadeOut",
									     OPTIONS = {duration = 0.15, revertable = true},
								     },
							       },
						  },
						  {
							CLASS = "action.QSBTeleportToAbsolutePosition",
							OPTIONS = {pos={x = 1250,y = 460},verify_flip = true},
						  },
						  {
							CLASS = "composite.QSBParallel",
							ARGS = {
								     {
									     CLASS = "action.QSBPlayEffect",
									     OPTIONS = {is_hit_effect = true},
								     },
								     {
									     CLASS = "action.QSBActorFadeIn",
									     OPTIONS = {duration = 0.15, revertable = true},
								     },
							       },
						  },
                        },
             },				-- 放激光
			 {
					CLASS = "composite.QSBParallel",
					ARGS = {
						     {
							     CLASS = "action.QSBPlaySound",
						     },  
						     {
							     CLASS = "composite.QSBSequence",
							     ARGS = {
                                             {
                                                 CLASS = "action.QSBPlaySceneEffect",
                                                 OPTIONS = {effect_id = "xiemohujingboss_jiguang", pos  = {x = 1020 , y = 520}, ground_layer = true},
                                             },
                                             {
									           CLASS = "action.QSBDelayTime",
									           OPTIONS = {delay_time = 27.5/24},
								             },
                                             {
                                                 CLASS = "action.QSBPlaySceneEffect",
                                                 OPTIONS = {effect_id = "xiemohujingboss_jiguang", pos  = {x = 1020 , y = 520}, ground_layer = true},
                                             },
                                             {
									           CLASS = "action.QSBDelayTime",
									           OPTIONS = {delay_time = 27.5/24},
								             },
                                             {
                                                 CLASS = "action.QSBPlaySceneEffect",
                                                 OPTIONS = {effect_id = "xiemohujingboss_jiguang", pos  = {x = 1020 , y = 360}, ground_layer = true},
                                             },
                                             {
                                                 CLASS = "action.QSBPlaySceneEffect",
                                                 OPTIONS = {effect_id = "xiemohujingboss_jiguang", pos  = {x = 1020 , y = 520}, ground_layer = true},
                                             },
                                             {
									           CLASS = "action.QSBDelayTime",
									           OPTIONS = {delay_time = 27.5/24},
								             },
                                             {
                                                 CLASS = "action.QSBPlaySceneEffect",
                                                 OPTIONS = {effect_id = "xiemohujingboss_jiguang", pos  = {x = 1020 , y = 360}, ground_layer = true},
                                             },
                                             {
                                                 CLASS = "action.QSBPlaySceneEffect",
                                                 OPTIONS = {effect_id = "xiemohujingboss_jiguang", pos  = {x = 1020 , y = 520}, ground_layer = true},
                                             },
                                             {
									           CLASS = "action.QSBDelayTime",
									           OPTIONS = {delay_time = 27.5/24},
								             },
                                             {
                                                 CLASS = "action.QSBPlaySceneEffect",
                                                 OPTIONS = {effect_id = "xiemohujingboss_jiguang", pos  = {x = 1020 , y = 360}, ground_layer = true},
                                             },
                                             {
									           CLASS = "action.QSBDelayTime",
									           OPTIONS = {delay_time = 27.5/24},
								             },
                                             {
                                                 CLASS = "action.QSBPlaySceneEffect",
                                                 OPTIONS = {effect_id = "xiemohujingboss_jiguang", pos  = {x = 1020 , y = 360}, ground_layer = true},
                                             },
                                             {
									           CLASS = "action.QSBDelayTime",
									           OPTIONS = {delay_time = 27.5/24},
								             },
                                             {
                                                 CLASS = "action.QSBPlaySceneEffect",
                                                 OPTIONS = {effect_id = "xiemohujingboss_jiguang", pos  = {x = 1020 , y = 360}, ground_layer = true},
                                             },
                                             {
									           CLASS = "action.QSBDelayTime",
									           OPTIONS = {delay_time = 27.5/24},
								             },
                                             {
                                                 CLASS = "action.QSBPlaySceneEffect",
                                                 OPTIONS = {effect_id = "xiemohujingboss_jiguang", pos  = {x = 1020 , y = 360}, ground_layer = true},
                                             },
							            },
						     },					
						     {
							      CLASS = "composite.QSBSequence",
							      ARGS = {
							               {
									           CLASS = "action.QSBDelayTime",
									           OPTIONS = {delay_frame = 50},
								           },
								           {
									           CLASS = "action.QSBPlayAnimation",
									           ARGS = {
										                 {
											                CLASS = "composite.QSBParallel",
											                ARGS = {
												                      {
													                     CLASS = "action.QSBPlayEffect",
													                     OPTIONS = {is_hit_effect = true},
												                      },
												                      {
													                     CLASS = "action.QSBHitTarget",
												                      },
											                       },
										                 },
									                  },
								           },
								           {
			                                   CLASS = "composite.QSBSequence",
			                                   ARGS = {
				---
				                                          {
							                                  CLASS = "composite.QSBParallel",
							                                  ARGS = {
								                                        {
									                                        CLASS = "action.QSBActorStand",
								                                        },
								                                        {
									                                        CLASS = "action.QSBActorFadeOut",
									                                        OPTIONS = {duration = 0.15, revertable = true},
								                                        },
							                                         },
						                                  },
						                                  {
							                                  CLASS = "action.QSBTeleportToAbsolutePosition",
							                                  OPTIONS = {pos={x = 1200,y = 300},verify_flip = true},
						                                  },
						                                  {
							                                  CLASS = "composite.QSBParallel",
							                                  ARGS = {
								                                        {
									                                       CLASS = "action.QSBPlayEffect",
									                                       OPTIONS = {is_hit_effect = true},
								                                        },
								                                        {
									                                       CLASS = "action.QSBActorFadeIn",
									                                       OPTIONS = {duration = 0.15, revertable = true},
								                                        },
							                                         },
						                                  },
                                                      },
                                           },
                                           {
									           CLASS = "action.QSBDelayTime",
									           OPTIONS = {delay_frame = 50},
								           },
								           {
                                               CLASS = "action.QSBSelectTarget",
                                               OPTIONS = {range_max = true},
                                           },
								           {
									           CLASS = "action.QSBPlayAnimation",
									           ARGS = {
										                 {
											                CLASS = "composite.QSBParallel",
											                ARGS = {
												                      {
													                     CLASS = "action.QSBPlayEffect",
													                     OPTIONS = {is_hit_effect = true},
												                      },
												                      {
													                     CLASS = "action.QSBHitTarget",
												                      },
											                       },
										                 },
									                  },
								           },				-- 放激光
								           {
									          CLASS = "action.QSBRemoveBuff",
									          OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
								           },
								           {
									          CLASS = "action.QSBAttackFinish"
								           },
							             },
						     },
					       },
		    },
		},
}
return boss_xiemohujing_jiguang1