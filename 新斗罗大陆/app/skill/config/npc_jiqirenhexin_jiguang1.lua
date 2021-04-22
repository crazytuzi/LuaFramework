local boss_niumang_dazhao = 
{
	CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
    	{
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack02"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "nengliangqiu_diancihuan"},
        },
    	{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 24 / 24},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
------1
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "diliepo_yujing10",
                                args = 
                                {
                                    {delay_time = 25 / 24 , pos = { x = 660, y = 200}} ,
                                    {delay_time = 26 / 24 , pos = { x = 660, y = 250}} ,
                                    {delay_time = 27 / 24 , pos = { x = 660, y = 300}} ,
                                    {delay_time = 28 / 24 , pos = { x = 660, y = 350}} ,
                                    {delay_time = 29 / 24 , pos = { x = 660, y = 400}} ,
                                    {delay_time = 30 / 24 , pos = { x = 660, y = 450}} ,
                                    {delay_time = 31 / 24 , pos = { x = 660, y = 500}} ,
                                    {delay_time = 32 / 24 , pos = { x = 660, y = 550}} ,
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "diliepo_yujing11",
                                args = 
                                {
                                    {delay_time = 29 / 24 , pos = { x = 660, y = 200}} ,
                                    {delay_time = 30 / 24 , pos = { x = 660, y = 250}} ,
                                    {delay_time = 31 / 24 , pos = { x = 660, y = 300}} ,
                                    {delay_time = 32 / 24 , pos = { x = 660, y = 350}} ,
                                    {delay_time = 33 / 24 , pos = { x = 660, y = 400}} ,
                                    {delay_time = 34 / 24 , pos = { x = 660, y = 450}} ,
                                    {delay_time = 35 / 24 , pos = { x = 660, y = 500}} ,
                                    {delay_time = 36 / 24 , pos = { x = 660, y = 550}} ,
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "diliepo_jiguang4",
                                args = 
                                {
                                    -- {delay_time = 109 / 24 , pos = { x = 660, y = 200}} ,
                                    {delay_time = 111 / 24 , pos = { x = 660, y = 250}} ,
                                    {delay_time = 113 / 24 , pos = { x = 660, y = 300}} ,
                                    {delay_time = 115 / 24 , pos = { x = 660, y = 350}} ,
                                    {delay_time = 117 / 24 , pos = { x = 660, y = 400}} ,
                                    {delay_time = 119 / 24 , pos = { x = 660, y = 450}} ,
                                    {delay_time = 121 / 24 , pos = { x = 660, y = 500}} ,
                                    {delay_time = 123 / 24 , pos = { x = 660, y = 550}} ,
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 111/ 24 },
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 12, duration = 0.45, count = 1},
                                },
                            },
                        },
-------------------2
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 36 / 24},
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_yujing10",
                                                args = 
                                                {
                                                    -- {delay_time = 25 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 26 / 24 , pos = { x = 630, y = 250}} ,
                                                    {delay_time = 27 / 24 , pos = { x = 600, y = 300}} ,
                                                    {delay_time = 28 / 24 , pos = { x = 570, y = 350}} ,
                                                    {delay_time = 29 / 24 , pos = { x = 540, y = 400}} ,
                                                    {delay_time = 30 / 24 , pos = { x = 510, y = 450}} ,
                                                    {delay_time = 31 / 24 , pos = { x = 480, y = 500}} ,
                                                    {delay_time = 32 / 24 , pos = { x = 450, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_yujing10",
                                                args = 
                                                {
                                                    -- {delay_time = 25 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 26 / 24 , pos = { x = 690, y = 250}} ,
                                                    {delay_time = 27 / 24 , pos = { x = 720, y = 300}} ,
                                                    {delay_time = 28 / 24 , pos = { x = 750, y = 350}} ,
                                                    {delay_time = 29 / 24 , pos = { x = 780, y = 400}} ,
                                                    {delay_time = 30 / 24 , pos = { x = 810, y = 450}} ,
                                                    {delay_time = 31 / 24 , pos = { x = 840, y = 500}} ,
                                                    {delay_time = 32 / 24 , pos = { x = 870, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_yujing11",
                                                args = 
                                                {
                                                    -- {delay_time = 29 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 30 / 24 , pos = { x = 630, y = 250}} ,
                                                    {delay_time = 31 / 24 , pos = { x = 600, y = 300}} ,
                                                    {delay_time = 32 / 24 , pos = { x = 570, y = 350}} ,
                                                    {delay_time = 33 / 24 , pos = { x = 540, y = 400}} ,
                                                    {delay_time = 34 / 24 , pos = { x = 510, y = 450}} ,
                                                    {delay_time = 35 / 24 , pos = { x = 480, y = 500}} ,
                                                    {delay_time = 36 / 24 , pos = { x = 450, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_yujing11",
                                                args = 
                                                {
                                                    -- {delay_time = 29 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 30 / 24 , pos = { x = 690, y = 250}} ,
                                                    {delay_time = 31 / 24 , pos = { x = 720, y = 300}} ,
                                                    {delay_time = 32 / 24 , pos = { x = 750, y = 350}} ,
                                                    {delay_time = 33 / 24 , pos = { x = 780, y = 400}} ,
                                                    {delay_time = 34 / 24 , pos = { x = 810, y = 450}} ,
                                                    {delay_time = 35 / 24 , pos = { x = 840, y = 500}} ,
                                                    {delay_time = 36 / 24 , pos = { x = 870, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_jiguang4",
                                                args = 
                                                {
                                                    -- {delay_time = 109 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 111 / 24 , pos = { x = 630, y = 250}} ,
                                                    {delay_time = 113 / 24 , pos = { x = 600, y = 300}} ,
                                                    {delay_time = 115 / 24 , pos = { x = 570, y = 350}} ,
                                                    {delay_time = 117 / 24 , pos = { x = 540, y = 400}} ,
                                                    {delay_time = 119 / 24 , pos = { x = 510, y = 450}} ,
                                                    {delay_time = 121 / 24 , pos = { x = 480, y = 500}} ,
                                                    {delay_time = 123 / 24 , pos = { x = 450, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_jiguang4",
                                                args = 
                                                {
                                                    -- {delay_time = 109 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 111 / 24 , pos = { x = 690, y = 250}} ,
                                                    {delay_time = 113 / 24 , pos = { x = 720, y = 300}} ,
                                                    {delay_time = 115 / 24 , pos = { x = 750, y = 350}} ,
                                                    {delay_time = 117 / 24 , pos = { x = 780, y = 400}} ,
                                                    {delay_time = 119 / 24 , pos = { x = 810, y = 450}} ,
                                                    {delay_time = 121 / 24 , pos = { x = 840, y = 500}} ,
                                                    {delay_time = 123 / 24 , pos = { x = 870, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 111/ 24 },
                                                },
                                                {
                                                    CLASS = "action.QSBShakeScreen",
                                                    OPTIONS = {amplitude = 12, duration = 0.45, count = 1},
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
-------------3
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 72 / 24},
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_yujing10",
                                                args = 
                                                {
                                                    -- {delay_time = 25 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 26 / 24 , pos = { x = 615, y = 239}} ,
                                                    {delay_time = 27 / 24 , pos = { x = 570, y = 278}} ,
                                                    {delay_time = 28 / 24 , pos = { x = 525, y = 317}} ,
                                                    {delay_time = 29 / 24 , pos = { x = 480, y = 356}} ,
                                                    {delay_time = 30 / 24 , pos = { x = 435, y = 395}} ,
                                                    {delay_time = 31 / 24 , pos = { x = 390, y = 434}} ,
                                                    {delay_time = 32 / 24 , pos = { x = 345, y = 473}} ,
                                                    {delay_time = 33 / 24 , pos = { x = 300, y = 512}} ,
                                                    {delay_time = 34 / 24 , pos = { x = 250, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_yujing10",
                                                args = 
                                                {
                                                    -- {delay_time = 25 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 26 / 24 , pos = { x = 705, y = 239}} ,
                                                    {delay_time = 27 / 24 , pos = { x = 750, y = 278}} ,
                                                    {delay_time = 28 / 24 , pos = { x = 795, y = 317}} ,
                                                    {delay_time = 29 / 24 , pos = { x = 840, y = 356}} ,
                                                    {delay_time = 30 / 24 , pos = { x = 885, y = 395}} ,
                                                    {delay_time = 31 / 24 , pos = { x = 930, y = 434}} ,
                                                    {delay_time = 32 / 24 , pos = { x = 975, y = 473}} ,
                                                    {delay_time = 33 / 24 , pos = { x = 1020, y = 512}} ,
                                                    {delay_time = 34 / 24 , pos = { x = 1065, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_yujing11",
                                                args = 
                                                {
                                                    -- {delay_time = 29 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 30 / 24 , pos = { x = 615, y = 239}} ,
                                                    {delay_time = 31 / 24 , pos = { x = 570, y = 278}} ,
                                                    {delay_time = 32 / 24 , pos = { x = 525, y = 317}} ,
                                                    {delay_time = 33 / 24 , pos = { x = 480, y = 356}} ,
                                                    {delay_time = 34 / 24 , pos = { x = 435, y = 395}} ,
                                                    {delay_time = 35 / 24 , pos = { x = 390, y = 434}} ,
                                                    {delay_time = 36 / 24 , pos = { x = 345, y = 473}} ,
                                                    {delay_time = 37 / 24 , pos = { x = 300, y = 512}} ,
                                                    {delay_time = 38 / 24 , pos = { x = 250, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_yujing11",
                                                args = 
                                               {
                                                    -- {delay_time = 29 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 30 / 24 , pos = { x = 705, y = 239}} ,
                                                    {delay_time = 31 / 24 , pos = { x = 750, y = 278}} ,
                                                    {delay_time = 32 / 24 , pos = { x = 795, y = 317}} ,
                                                    {delay_time = 33 / 24 , pos = { x = 840, y = 356}} ,
                                                    {delay_time = 34 / 24 , pos = { x = 885, y = 395}} ,
                                                    {delay_time = 35 / 24 , pos = { x = 930, y = 434}} ,
                                                    {delay_time = 36 / 24 , pos = { x = 975, y = 473}} ,
                                                    {delay_time = 37 / 24 , pos = { x = 1020, y = 512}} ,
                                                    {delay_time = 38 / 24 , pos = { x = 1065, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_jiguang4",
                                                args = 
                                                {
                                                    -- {delay_time = 111 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 113 / 24 , pos = { x = 705, y = 239}} ,
                                                    {delay_time = 115 / 24 , pos = { x = 750, y = 278}} ,
                                                    {delay_time = 117 / 24 , pos = { x = 795, y = 317}} ,
                                                    {delay_time = 119 / 24 , pos = { x = 840, y = 356}} ,
                                                    {delay_time = 121 / 24 , pos = { x = 885, y = 395}} ,
                                                    {delay_time = 123 / 24 , pos = { x = 930, y = 434}} ,
                                                    {delay_time = 125 / 24 , pos = { x = 975, y = 473}} ,
                                                    {delay_time = 127 / 24 , pos = { x = 1020, y = 512}} ,
                                                    {delay_time = 129 / 24 , pos = { x = 1065, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_jiguang4",
                                                args = 
                                                {
                                                    -- {delay_time = 111 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 113 / 24 , pos = { x = 615, y = 239}} ,
                                                    {delay_time = 115 / 24 , pos = { x = 570, y = 278}} ,
                                                    {delay_time = 117 / 24 , pos = { x = 525, y = 317}} ,
                                                    {delay_time = 119 / 24 , pos = { x = 480, y = 356}} ,
                                                    {delay_time = 121 / 24 , pos = { x = 435, y = 395}} ,
                                                    {delay_time = 123 / 24 , pos = { x = 390, y = 434}} ,
                                                    {delay_time = 125 / 24 , pos = { x = 345, y = 473}} ,
                                                    {delay_time = 127 / 24 , pos = { x = 300, y = 512}} ,
                                                    {delay_time = 129 / 24 , pos = { x = 250, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 111/ 24 },
                                                },
                                                {
                                                    CLASS = "action.QSBShakeScreen",
                                                    OPTIONS = {amplitude = 12, duration = 0.45, count = 1},
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },

-------------4
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 108 / 24},
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_yujing10",
                                                args = 
                                                {
                                                    -- {delay_time = 25 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 26 / 24 , pos = { x = 600, y = 235}} ,
                                                    {delay_time = 27 / 24 , pos = { x = 540, y = 270}} ,
                                                    {delay_time = 28 / 24 , pos = { x = 480, y = 305}} ,
                                                    {delay_time = 29 / 24 , pos = { x = 420, y = 340}} ,
                                                    {delay_time = 30 / 24 , pos = { x = 360, y = 375}} ,
                                                    {delay_time = 31 / 24 , pos = { x = 300, y = 410}} ,
                                                    {delay_time = 32 / 24 , pos = { x = 240, y = 445}} ,
                                                    {delay_time = 33 / 24 , pos = { x = 180, y = 480}} ,
                                                    {delay_time = 34 / 24 , pos = { x = 120, y = 515}} ,
                                                    {delay_time = 35 / 24 , pos = { x = 60, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_yujing10",
                                                args = 
                                                {
                                                    -- {delay_time = 25 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 26 / 24 , pos = { x = 720, y = 235}} ,
                                                    {delay_time = 27 / 24 , pos = { x = 780, y = 270}} ,
                                                    {delay_time = 28 / 24 , pos = { x = 840, y = 305}} ,
                                                    {delay_time = 29 / 24 , pos = { x = 900, y = 340}} ,
                                                    {delay_time = 30 / 24 , pos = { x = 960, y = 375}} ,
                                                    {delay_time = 31 / 24 , pos = { x = 1020, y = 410}} ,
                                                    {delay_time = 32 / 24 , pos = { x = 1080, y = 445}} ,
                                                    {delay_time = 33 / 24 , pos = { x = 1140, y = 480}} ,
                                                    {delay_time = 34 / 24 , pos = { x = 1200, y = 515}} ,
                                                    {delay_time = 35 / 24 , pos = { x = 1260, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_yujing11",
                                                args = 
                                                {
                                                    -- {delay_time = 29 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 30 / 24 , pos = { x = 600, y = 235}} ,
                                                    {delay_time = 31 / 24 , pos = { x = 540, y = 270}} ,
                                                    {delay_time = 32/ 24 , pos = { x = 480, y = 305}} ,
                                                    {delay_time = 33 / 24 , pos = { x = 420, y = 340}} ,
                                                    {delay_time = 34 / 24 , pos = { x = 360, y = 375}} ,
                                                    {delay_time = 35 / 24 , pos = { x = 300, y = 410}} ,
                                                    {delay_time = 36 / 24 , pos = { x = 240, y = 445}} ,
                                                    {delay_time = 37 / 24 , pos = { x = 180, y = 480}} ,
                                                    {delay_time = 38 / 24 , pos = { x = 120, y = 515}} ,
                                                    {delay_time = 39 / 24 , pos = { x = 60, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_yujing11",
                                                args = 
                                                {
                                                    -- {delay_time = 29 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 30 / 24 , pos = { x = 720, y = 235}} ,
                                                    {delay_time = 31 / 24 , pos = { x = 780, y = 270}} ,
                                                    {delay_time = 32 / 24 , pos = { x = 840, y = 305}} ,
                                                    {delay_time = 33 / 24 , pos = { x = 900, y = 340}} ,
                                                    {delay_time = 34 / 24 , pos = { x = 960, y = 375}} ,
                                                    {delay_time = 35 / 24 , pos = { x = 1020, y = 410}} ,
                                                    {delay_time = 36 / 24 , pos = { x = 1080, y = 445}} ,
                                                    {delay_time = 37 / 24 , pos = { x = 1140, y = 480}} ,
                                                    {delay_time = 38 / 24 , pos = { x = 1200, y = 515}} ,
                                                    {delay_time = 39 / 24 , pos = { x = 1260, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_jiguang4",
                                                args = 
                                                {
                                                    -- {delay_time = 111 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 113 / 24 , pos = { x = 600, y = 235}} ,
                                                    {delay_time = 115 / 24 , pos = { x = 540, y = 270}} ,
                                                    {delay_time = 117 / 24 , pos = { x = 480, y = 305}} ,
                                                    {delay_time = 119 / 24 , pos = { x = 420, y = 340}} ,
                                                    {delay_time = 121 / 24 , pos = { x = 360, y = 375}} ,
                                                    {delay_time = 123 / 24 , pos = { x = 300, y = 410}} ,
                                                    {delay_time = 125 / 24 , pos = { x = 240, y = 445}} ,
                                                    {delay_time = 127 / 24 , pos = { x = 180, y = 480}} ,
                                                    {delay_time = 129 / 24 , pos = { x = 120, y = 515}} ,
                                                    {delay_time = 131 / 24 , pos = { x = 60, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap",  
                                            OPTIONS = 
                                            { 
                                                trapId = "diliepo_jiguang4",
                                                args = 
                                                {
                                                    -- {delay_time = 111 / 24 , pos = { x = 660, y = 200}} ,
                                                    {delay_time = 113 / 24 , pos = { x = 720, y = 235}} ,
                                                    {delay_time = 115 / 24 , pos = { x = 780, y = 270}} ,
                                                    {delay_time = 117 / 24 , pos = { x = 840, y = 305}} ,
                                                    {delay_time = 119 / 24 , pos = { x = 900, y = 340}} ,
                                                    {delay_time = 121 / 24 , pos = { x = 960, y = 375}} ,
                                                    {delay_time = 123 / 24 , pos = { x = 1020, y = 410}} ,
                                                    {delay_time = 125 / 24 , pos = { x = 1080, y = 445}} ,
                                                    {delay_time = 127 / 24 , pos = { x = 1140, y = 480}} ,
                                                    {delay_time = 129 / 24 , pos = { x = 1200, y = 515}} ,
                                                    {delay_time = 131 / 24 , pos = { x = 1260, y = 550}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 111/ 24 },
                                                },
                                                {
                                                    CLASS = "action.QSBShakeScreen",
                                                    OPTIONS = {amplitude = 12, duration = 0.45, count = 1},
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
--------4
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
			},
		},
	},
}
return boss_niumang_dazhao