--[[
界面画模型时的灯光参数
lizhuangzhuang
2014年11月11日10:44:06
]]

_G.UIDrawLightCfg = 
{	
	--默认
	Default = 
	{
		SkyLight = 
		{
			color = 0xffd7e7f6,
			power = 0.6,
		},
		AmbientLight = 
		{
			color = 0xffffffff,
		},
		--天光的一种方式
		Backlight =
        {
			color = 0xffffffff,
			power = 2,
        }
		
	},
	--角色界面
	UIRole = 
	{
        [enProfType.eProfType_Sickle]= --萝莉
        {
            SkyLight =
            {
                color = 0xffcde4f9,
                power = 0.4,
            },
            AmbientLight =
            {
                color = 0xffffffff,
            },
			Backlight =
			{
				color = 0xffdfe7fa,
				power = 1,
			}
        },
        [enProfType.eProfType_Sword]= --男魔
        {
            SkyLight =
            {
                color = 0xffd7e7f6,
                power = 0.5,
            },
            AmbientLight =
            {
                color = 0xffffffff,
            },
			Backlight =
			{
				color = 0xffffe2b0,
				power = 2,
			}

        },
		[enProfType.eProfType_Human]= --男人
        {
            SkyLight =
            {
                color = 0xffd7e7f6,
                power = 0.5,
            },
            AmbientLight =
            {
                color = 0xffffffff,
            },
			Backlight =
			{
				color = 0xffffffff,
				power = 2,
			}

        },

        [enProfType.eProfType_Woman]= --御姐
        {
            SkyLight =
            {
                color = 0xffb0d9ec,
                power = 0.8,
            },
            AmbientLight =
            {
                color = 0xffd4d4d4,
            },
			Backlight =
			{
				color = 0xffb8e2e6,
				power = 18,
			}

        }
	},
	--NPC面板
	UINpc = 
	{
		SkyLight = 
		{
			color = 0xffd5e3f9,
			power = 0.4,
		},
		AmbientLight = 
		{
			color = 0xffe6ecfb,
		},
		Backlight =
		{
			color = 0xff91b6ed,
			power = 2,
		}
	},
	-- 噬魂怪物面板
	UIShihunMonster = 
	{
		SkyLight = 
		{
			color = 0xffcae4fa,
			power = 0.7,
		},
		AmbientLight = 
		{
			color = 0xffe6ecfb,
		},
		Backlight =
		{
			color = 0xffbcb4ec,
			power = 1.5,
		}
	},
	-- 坐骑
	UIMount = 
	{
		SkyLight = 
		{
			color = 0xFFE8DAB2,
			power = 1.2,
		},
		AmbientLight = 
		{
			color = 0xd996B6C0,
		},
		Backlight =
		{
			color = 0xffffffff,
			power = 2,
		}
	},
	--神兵
	UIMagicWeapon = 
	{
		SkyLight = 
		{
			color = 0xffd7e7f6,
			power = 0.6,
		},
		AmbientLight = 
		{
			color = 0xffffffff,
		},
		Backlight =
        {
			color = 0xffffffff,
			power = 2,
        }
		
	},
		--灵兽
	UIMagicWeapon = 
	{
		SkyLight = 
		{
			color = 0xffd7e7f6,
			power = 0.6,
		},
		AmbientLight = 
		{
			color = 0xffffffff,
		},
		Backlight =
        {
			color = 0xffffffff,
			power = 2,
        }
		
	},
	--worldboss面板
	WorldBoss = 
	{
		SkyLight = 
		{
			color = 0xfffaf8e8,
			power = 0.4,
		},
		AmbientLight = 
		{
			color = 0xffe6ecfb,
		},
		Backlight =
		{
			color = 0xff91b6ed,
			power = 1.5,
		}
	},
	--斗破苍穹面板
	Babel = 
	{
		SkyLight = 
		{
			color = 0xfffaf8e8,
			power = 0.2,
		},
		AmbientLight = 
		{
			color = 0xffe6ecfb,
		},
		Backlight =
		{
			color = 0xff91b6ed,
			power = 1.5,
		}
	},
	--悬赏任务面板
	FengYao = 
	{
		SkyLight = 
		{
			color = 0xfffaf8e8,
			power = 0.5,
		},
		AmbientLight = 
		{
			color = 0xffe6ecfb,
		},
		Backlight =
		{
			color = 0xff91b6ed,
			power = 1.5,
		}
	},
	--翅膀Tips灯光
	UIWing = 
	{
		SkyLight = 
		{
			color = 0xffd7e7f6,
			power = 0.6,
		},
		AmbientLight = 
		{
			color = 0xffffffff,
		},
		Backlight =
        {
			color = 0xffffffff,
			power = 5,
        }
		
	},
	-- 帮派boss面板
	UIShihunMonster = 
	{
		SkyLight = 
		{
			color = 0xffcae4fa,
			power = 0.7,
		},
		AmbientLight = 
		{
			color = 0xffe6ecfb,
		},
		Backlight =
		{
			color = 0xffbcb4ec,
			power = 1.5,
		}
	},
};