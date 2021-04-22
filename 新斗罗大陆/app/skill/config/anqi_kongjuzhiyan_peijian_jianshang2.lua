	local anqi_kongjuzhiyan_shanghai6 ={
	    CLASS = "composite.QSBSequence",
	    ARGS = { 
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 4},
				},
				{
					CLASS = "action.QSBRemoveBuff",	
					OPTIONS = {buff_id = "anqi_kongjuzhiyan_kaiju_jianshang2"},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 90},
				},
				{
					CLASS = "action.QSBRemoveBuff",	
					OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_1"},
				},
				{
					CLASS = "action.QSBRemoveBuff",	
					OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_2"},
				},
				{
					CLASS = "action.QSBRemoveBuff",	
					OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_3"},
				},
				{
					CLASS = "action.QSBRemoveBuff",	
					OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_4"},
				},
				{
                    CLASS = "action.QSBArgsNumber",
                    OPTIONS = {is_all_enemies = true, status_number = true, stub_status = "kongjuzhiyan_ganran"},
                },
				-- {
					-- CLASS = "composite.QSBSelector",
					-- ARGS = {
						-- {
							-- CLASS = "action.QSBApplyBuff",
							-- OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang1_1"},
						-- },	
						-- {
							-- CLASS = "action.QSBApplyBuff",
							-- OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang1_2"},
						-- },	
						-- {
							-- CLASS = "action.QSBApplyBuff",
							-- OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang1_3"},
						-- },	
						-- {
							-- CLASS = "action.QSBApplyBuff",
							-- OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang1_4"},
						-- },	
					-- },
				-- },
				{
					CLASS = "composite.QSBSelectorByNumber",
					ARGS = 
					{       
						-- {
                            -- CLASS = "composite.QSBSequence",
                            -- OPTIONS = {flag = 0},
                            -- ARGS = {
								-- {
									-- CLASS = "action.QSBApplyBuff",
									-- OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_0"},
								-- },	
							-- },
						-- },
						{
                            CLASS = "composite.QSBSequence",
                            OPTIONS = {flag = 1},
                            ARGS = {
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_1"},
								},	
							},
						},
						{
                            CLASS = "composite.QSBSequence",
                            OPTIONS = {flag = 2},
                            ARGS = {
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_2"},
								},	
							},
						},
						{
                            CLASS = "composite.QSBSequence",
                            OPTIONS = {flag = 3},
                            ARGS = {
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_3"},
								},	
							},
						},
						{
                            CLASS = "composite.QSBSequence",
                            OPTIONS = {flag = 4, mode = "<="},
                            ARGS = {
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_4"},
								},	
							},
						},
						-- {
                            -- CLASS = "composite.QSBSequence",
                            -- OPTIONS = {flag = 5},
                            -- ARGS = {
								-- {
									-- CLASS = "action.QSBApplyBuff",
									-- OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_4"},
								-- },	
							-- },
						-- },
						-- {
                            -- CLASS = "composite.QSBSequence",
                            -- OPTIONS = {flag = 6},
                            -- ARGS = {
								-- {
									-- CLASS = "action.QSBApplyBuff",
									-- OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_4"},
								-- },	
							-- },
						-- },
						-- {
                            -- CLASS = "composite.QSBSequence",
                            -- OPTIONS = {flag = 7},
                            -- ARGS = {
								-- {
									-- CLASS = "action.QSBApplyBuff",
									-- OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_4"},
								-- },	
							-- },
						-- },
						-- {
                            -- CLASS = "composite.QSBSequence",
                            -- OPTIONS = {flag = 8},
                            -- ARGS = {
								-- {
									-- CLASS = "action.QSBApplyBuff",
									-- OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_4"},
								-- },	
							-- },
						-- },
						-- {
                            -- CLASS = "composite.QSBSequence",
                            -- OPTIONS = {flag = 9},
                            -- ARGS = {
								-- {
									-- CLASS = "action.QSBApplyBuff",
									-- OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_4"},
								-- },	
							-- },
						-- },
						-- {
                            -- CLASS = "composite.QSBSequence",
                            -- OPTIONS = {flag = 10},
                            -- ARGS = {
								-- {
									-- CLASS = "action.QSBApplyBuff",
									-- OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_4"},
								-- },	
							-- },
						-- },
						-- {
                            -- CLASS = "composite.QSBSequence",
                            -- OPTIONS = {flag = 11},
                            -- ARGS = {
								-- {
									-- CLASS = "action.QSBApplyBuff",
									-- OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_4"},
								-- },	
							-- },
						-- },
						-- {
                            -- CLASS = "composite.QSBSequence",
                            -- OPTIONS = {flag = 12},
                            -- ARGS = {
								-- {
									-- CLASS = "action.QSBApplyBuff",
									-- OPTIONS = {buff_id = "anqi_kongjuzhiyan_jianshang2_4"},
								-- },	
							-- },
						-- },
					},
				},
			{
				CLASS = "action.QSBPlayMountSkillAnimation",
			},
	    	{
	            CLASS = "action.QSBAttackFinish"
	        },
	    },
	}

return anqi_kongjuzhiyan_shanghai6




