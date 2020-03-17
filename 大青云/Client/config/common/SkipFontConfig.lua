_G.SkipFontConfig =
{

	[1001] =					--这个是敌人掉血的跳字配置
	{
		PfxName ="v_beijishuzi.pfx"; --对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};

		NetNumFunc = function(self) 		
			self.Num["down"] = CResStation:GetImage( "beiji-.png" );
			self.Num["0"] =	CResStation:GetImage( 'beiji0.png' );
			self.Num["1"] =	CResStation:GetImage( 'beiji1.png' );
			self.Num["2"] =	CResStation:GetImage( 'beiji2.png' );
			self.Num["3"] =	CResStation:GetImage( 'beiji3.png' );
			self.Num["4"] =	CResStation:GetImage( 'beiji4.png' );
			self.Num["5"] =	CResStation:GetImage( 'beiji5.png' );
			self.Num["6"] =	CResStation:GetImage( 'beiji6.png' );
			self.Num["7"] =	CResStation:GetImage( 'beiji7.png' );
			self.Num["8"] =	CResStation:GetImage( 'beiji8.png' );
			self.Num["9"] =	CResStation:GetImage( 'beiji9.png' );
			self.Num[","] =	CResStation:GetImage( 'beijidouhao.png' );
			--self.Num["sp"] = CResStation:GetImage( 'jingjieyazhi_shuzi.png' );
		end
	};

	[1002] =					--这个是敌人掉血的暴击配置
	{
		PfxName ="v_baoji.pfx";--对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["crit"] = CResStation:GetImage( "baoji-.png" );
			self.Num["0"] =	CResStation:GetImage( 'baoji0.png' );
			self.Num["1"] =	CResStation:GetImage( 'baoji1.png' );
			self.Num["2"] =	CResStation:GetImage( 'baoji2.png' );
			self.Num["3"] =	CResStation:GetImage( 'baoji3.png' );
			self.Num["4"] =	CResStation:GetImage( 'baoji4.png' );
			self.Num["5"] =	CResStation:GetImage( 'baoji5.png' );
			self.Num["6"] =	CResStation:GetImage( 'baoji6.png' );
			self.Num["7"] =	CResStation:GetImage( 'baoji7.png' );
			self.Num["8"] =	CResStation:GetImage( 'baoji8.png' );
			self.Num["9"] =	CResStation:GetImage( 'baoji9.png' );
			self.Num[","] =	CResStation:GetImage( 'baojidouhao.png' );
			self.Num["shandian"] =	CResStation:GetImage( 'baojishandian.png' );
			--self.Num["sp"] = CResStation:GetImage( 'jingjieyazhi-baoji.png' );
		end
	};

	[1003] =			     	--这个是自己未命中时
	{
        PfxName ="v_weimingzhong.pfx";--对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["miss"] = CResStation:GetImage( "weimingzhong.png" );
		end
	};

	[1004] =					--这个是格挡了伤害的
	{
		PfxName ="v_gedang.pfx";--对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["defparry"] = CResStation:GetImage( "gedang.png" );
		end
	};

	[1005] =					--这个是闪避了伤害的
	{
		PfxName ="v_shanbi.pfx";--对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["dodge"] = CResStation:GetImage( "shanbi.png" );
		end

	};

	[1006] =					--这个是自己掉血的跳字配置
	{
		PfxName ="v_renwu_beijishuzi.pfx"; --对应的轨迹特效名
		BindPos = 'awc';--启动的绑点，人用这个
		Num={};

		NetNumFunc = function(self) 		
			self.Num["down"] = CResStation:GetImage( "renwu_beiji-.png" );
			self.Num["0"] =	CResStation:GetImage( 'renwu_beiji0.png' );
			self.Num["1"] =	CResStation:GetImage( 'renwu_beiji1.png' );
			self.Num["2"] =	CResStation:GetImage( 'renwu_beiji2.png' );
			self.Num["3"] =	CResStation:GetImage( 'renwu_beiji3.png' );
			self.Num["4"] =	CResStation:GetImage( 'renwu_beiji4.png' );
			self.Num["5"] =	CResStation:GetImage( 'renwu_beiji5.png' );
			self.Num["6"] =	CResStation:GetImage( 'renwu_beiji6.png' );
			self.Num["7"] =	CResStation:GetImage( 'renwu_beiji7.png' );
			self.Num["8"] =	CResStation:GetImage( 'renwu_beiji8.png' );
			self.Num["9"] =	CResStation:GetImage( 'renwu_beiji9.png' );
		end
	};

	[1007] =					--这个是自己掉血的暴击配置
	{
		PfxName ="v_renwu_baoji.pfx";--对应的轨迹特效名
		BindPos = 'awc';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["crit"] = CResStation:GetImage( "renwu_baoji.png" );
			self.Num["0"] =	CResStation:GetImage( 'renwu_baoji0.png' );
			self.Num["1"] =	CResStation:GetImage( 'renwu_baoji1.png' );
			self.Num["2"] =	CResStation:GetImage( 'renwu_baoji2.png' );
			self.Num["3"] =	CResStation:GetImage( 'renwu_baoji3.png' );
			self.Num["4"] =	CResStation:GetImage( 'renwu_baoji4.png' );
			self.Num["5"] =	CResStation:GetImage( 'renwu_baoji5.png' );
			self.Num["6"] =	CResStation:GetImage( 'renwu_baoji6.png' );
			self.Num["7"] =	CResStation:GetImage( 'renwu_baoji7.png' );
			self.Num["8"] =	CResStation:GetImage( 'renwu_baoji8.png' );
			self.Num["9"] =	CResStation:GetImage( 'renwu_baoji9.png' );
		end
	};

	[1008] =			     	--这个是自己未命中时
	{
        PfxName ="v_weimingzhong.pfx";--对应的轨迹特效名
		BindPos = 'awc';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["miss"] = CResStation:GetImage( "weimingzhong.png" );
		end
	};

	[1009] =					--这个是格挡了伤害的
	{
		PfxName ="v_gedang.pfx";--对应的轨迹特效名
		BindPos = 'awc';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["defparry"] = CResStation:GetImage( "gedang.png" );
		end
	};

	[1010] =					--这个是闪避了伤害的
	{
		PfxName ="v_shanbi.pfx";--对应的轨迹特效名
		BindPos = 'awc';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["dodge"] = CResStation:GetImage( "shanbi.png" );
		end
	};

	[1011] =					--这个是敌人掉血的跳字配置 多段伤害造成的
	{
		PfxName ="v_duoduan_shanghai.pfx"; --对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};

		NetNumFunc = function(self) 		
			self.Num["down"] = CResStation:GetImage( "beiji-.png" );
			self.Num["0"] =	CResStation:GetImage( 'beiji0.png' );
			self.Num["1"] =	CResStation:GetImage( 'beiji1.png' );
			self.Num["2"] =	CResStation:GetImage( 'beiji2.png' );
			self.Num["3"] =	CResStation:GetImage( 'beiji3.png' );
			self.Num["4"] =	CResStation:GetImage( 'beiji4.png' );
			self.Num["5"] =	CResStation:GetImage( 'beiji5.png' );
			self.Num["6"] =	CResStation:GetImage( 'beiji6.png' );
			self.Num["7"] =	CResStation:GetImage( 'beiji7.png' );
			self.Num["8"] =	CResStation:GetImage( 'beiji8.png' );
			self.Num["9"] =	CResStation:GetImage( 'beiji9.png' );
			self.Num[","] =	CResStation:GetImage( 'beijidouhao.png' );
		end
	};
	[1012] =					--这个是敌人掉血的暴击配置 多段伤害造成的
	{
		PfxName ="v_duoduan_baoji.pfx";--对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["crit"] = CResStation:GetImage( "baoji-.png" );
			self.Num["0"] =	CResStation:GetImage( 'baoji0.png' );
			self.Num["1"] =	CResStation:GetImage( 'baoji1.png' );
			self.Num["2"] =	CResStation:GetImage( 'baoji2.png' );
			self.Num["3"] =	CResStation:GetImage( 'baoji3.png' );
			self.Num["4"] =	CResStation:GetImage( 'baoji4.png' );
			self.Num["5"] =	CResStation:GetImage( 'baoji5.png' );
			self.Num["6"] =	CResStation:GetImage( 'baoji6.png' );
			self.Num["7"] =	CResStation:GetImage( 'baoji7.png' );
			self.Num["8"] =	CResStation:GetImage( 'baoji8.png' );
			self.Num["9"] =	CResStation:GetImage( 'baoji9.png' );
			self.Num[","] =	CResStation:GetImage( 'baojidouhao.png' );
			self.Num["shandian"] =	CResStation:GetImage( 'baojishandian.png' );
		end
	};

	[1013] =					--回血
	{
		PfxName ="v_renwu_hpmpshuzi.pfx"; --对应的轨迹特效名
		BindPos = 'awc';--启动的绑点，人用这个
		Num={};

		NetNumFunc = function(self) 		
			self.Num["+"] = CResStation:GetImage( "hp+.png" );
			self.Num["0"] =	CResStation:GetImage( 'hp0.png' );
			self.Num["1"] =	CResStation:GetImage( 'hp1.png' );
			self.Num["2"] =	CResStation:GetImage( 'hp2.png' );
			self.Num["3"] =	CResStation:GetImage( 'hp3.png' );
			self.Num["4"] =	CResStation:GetImage( 'hp4.png' );
			self.Num["5"] =	CResStation:GetImage( 'hp5.png' );
			self.Num["6"] =	CResStation:GetImage( 'hp6.png' );
			self.Num["7"] =	CResStation:GetImage( 'hp7.png' );
			self.Num["8"] =	CResStation:GetImage( 'hp8.png' );
			self.Num["9"] =	CResStation:GetImage( 'hp9.png' );
		end
	};
	[1014] =					--回蓝
	{
		PfxName ="v_renwu_hpmpshuzi.pfx";--对应的轨迹特效名
		BindPos = 'awc';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["+"] = CResStation:GetImage( "mp+.png" );
			self.Num["0"] =	CResStation:GetImage( 'mp0.png' );
			self.Num["1"] =	CResStation:GetImage( 'mp1.png' );
			self.Num["2"] =	CResStation:GetImage( 'mp2.png' );
			self.Num["3"] =	CResStation:GetImage( 'mp3.png' );
			self.Num["4"] =	CResStation:GetImage( 'mp4.png' );
			self.Num["5"] =	CResStation:GetImage( 'mp5.png' );
			self.Num["6"] =	CResStation:GetImage( 'mp6.png' );
			self.Num["7"] =	CResStation:GetImage( 'mp7.png' );
			self.Num["8"] =	CResStation:GetImage( 'mp8.png' );
			self.Num["9"] =	CResStation:GetImage( 'mp9.png' );
		end
	};


	[1015] =					--坐骑技能普通伤害
	{
		PfxName ="v_beijishuzi.pfx"; --对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["down"] = CResStation:GetImage( "zuoqibeiji-.png" );
			self.Num["0"] =	CResStation:GetImage( 'zuoqibeiji0.png' );
			self.Num["1"] =	CResStation:GetImage( 'zuoqibeiji1.png' );
			self.Num["2"] =	CResStation:GetImage( 'zuoqibeiji2.png' );
			self.Num["3"] =	CResStation:GetImage( 'zuoqibeiji3.png' );
			self.Num["4"] =	CResStation:GetImage( 'zuoqibeiji4.png' );
			self.Num["5"] =	CResStation:GetImage( 'zuoqibeiji5.png' );
			self.Num["6"] =	CResStation:GetImage( 'zuoqibeiji6.png' );
			self.Num["7"] =	CResStation:GetImage( 'zuoqibeiji7.png' );
			self.Num["8"] =	CResStation:GetImage( 'zuoqibeiji8.png' );
			self.Num["9"] =	CResStation:GetImage( 'zuoqibeiji9.png' );
			self.Num[","] =	CResStation:GetImage( 'zuoqibeijidouhao.png' );
		end
	};

	[1016] =					--坐骑技能暴击伤害
	{
		PfxName ="v_baoji.pfx";--对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["crit"] = CResStation:GetImage( "zuoqibaoji-.png" );
			self.Num["0"] =	CResStation:GetImage( 'zuoqibaoji0.png' );
			self.Num["1"] =	CResStation:GetImage( 'zuoqibaoji1.png' );
			self.Num["2"] =	CResStation:GetImage( 'zuoqibaoji2.png' );
			self.Num["3"] =	CResStation:GetImage( 'zuoqibaoji3.png' );
			self.Num["4"] =	CResStation:GetImage( 'zuoqibaoji4.png' );
			self.Num["5"] =	CResStation:GetImage( 'zuoqibaoji5.png' );
			self.Num["6"] =	CResStation:GetImage( 'zuoqibaoji6.png' );
			self.Num["7"] =	CResStation:GetImage( 'zuoqibaoji7.png' );
			self.Num["8"] =	CResStation:GetImage( 'zuoqibaoji8.png' );
			self.Num["9"] =	CResStation:GetImage( 'zuoqibaoji9.png' );
			self.Num[","] =	CResStation:GetImage( 'zuoqibaojidouhao.png' );
			self.Num["shandian"] =	CResStation:GetImage( 'zuoqibaojishandian.png' );
		end
	};

	[1017] =					--灵兽技能普通伤害
	{
		PfxName ="v_beijishuzi.pfx"; --对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["down"] = CResStation:GetImage( "lingshoubeiji-.png" );
			self.Num["0"] =	CResStation:GetImage( 'lingshoubeiji0.png' );
			self.Num["1"] =	CResStation:GetImage( 'lingshoubeiji1.png' );
			self.Num["2"] =	CResStation:GetImage( 'lingshoubeiji2.png' );
			self.Num["3"] =	CResStation:GetImage( 'lingshoubeiji3.png' );
			self.Num["4"] =	CResStation:GetImage( 'lingshoubeiji4.png' );
			self.Num["5"] =	CResStation:GetImage( 'lingshoubeiji5.png' );
			self.Num["6"] =	CResStation:GetImage( 'lingshoubeiji6.png' );
			self.Num["7"] =	CResStation:GetImage( 'lingshoubeiji7.png' );
			self.Num["8"] =	CResStation:GetImage( 'lingshoubeiji8.png' );
			self.Num["9"] =	CResStation:GetImage( 'lingshoubeiji9.png' );
			self.Num[","] =	CResStation:GetImage( 'lingshoubeijidouhao.png' );
		end
	};

	[1018] =					--灵兽技能暴击伤害
	{
		PfxName ="v_baoji.pfx";--对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["crit"] = CResStation:GetImage( "lingshoubaoji-.png" );
			self.Num["0"] =	CResStation:GetImage( 'lingshoubaoji0.png' );
			self.Num["1"] =	CResStation:GetImage( 'lingshoubaoji1.png' );
			self.Num["2"] =	CResStation:GetImage( 'lingshoubaoji2.png' );
			self.Num["3"] =	CResStation:GetImage( 'lingshoubaoji3.png' );
			self.Num["4"] =	CResStation:GetImage( 'lingshoubaoji4.png' );
			self.Num["5"] =	CResStation:GetImage( 'lingshoubaoji5.png' );
			self.Num["6"] =	CResStation:GetImage( 'lingshoubaoji6.png' );
			self.Num["7"] =	CResStation:GetImage( 'lingshoubaoji7.png' );
			self.Num["8"] =	CResStation:GetImage( 'lingshoubaoji8.png' );
			self.Num["9"] =	CResStation:GetImage( 'lingshoubaoji9.png' );
			self.Num[","] =	CResStation:GetImage( 'lingshoubaojidouhao.png' );
			self.Num["shandian"] =	CResStation:GetImage( 'lingshoubaojishandian.png' );
		end
	};


	[1019] =					--神兵技能普通伤害
	{
		PfxName ="v_beijishuzi.pfx"; --对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self)
			self.Num["down"] = CResStation:GetImage( "shenbing.png" );
			self.Num["0"] =	CResStation:GetImage( 'shenbing0.png' );
			self.Num["1"] =	CResStation:GetImage( 'shenbing1.png' );
			self.Num["2"] =	CResStation:GetImage( 'shenbing2.png' );
			self.Num["3"] =	CResStation:GetImage( 'shenbing3.png' );
			self.Num["4"] =	CResStation:GetImage( 'shenbing4.png' );
			self.Num["5"] =	CResStation:GetImage( 'shenbing5.png' );
			self.Num["6"] =	CResStation:GetImage( 'shenbing6.png' );
			self.Num["7"] =	CResStation:GetImage( 'shenbing7.png' );
			self.Num["8"] =	CResStation:GetImage( 'shenbing8.png' );
			self.Num["9"] =	CResStation:GetImage( 'shenbing9.png' );
			self.Num[","] =	CResStation:GetImage( 'shenbingbeijidouhao.png' );
		end
	};

	[1020] =					--神兵技能暴击伤害
	{
		PfxName ="v_baoji.pfx";--对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["crit"] = CResStation:GetImage( "shenbing.png" );
			self.Num["0"] =	CResStation:GetImage( 'shenbing0.png' );
			self.Num["1"] =	CResStation:GetImage( 'shenbing1.png' );
			self.Num["2"] =	CResStation:GetImage( 'shenbing2.png' );
			self.Num["3"] =	CResStation:GetImage( 'shenbing3.png' );
			self.Num["4"] =	CResStation:GetImage( 'shenbing4.png' );
			self.Num["5"] =	CResStation:GetImage( 'shenbing5.png' );
			self.Num["6"] =	CResStation:GetImage( 'shenbing6.png' );
			self.Num["7"] =	CResStation:GetImage( 'shenbing7.png' );
			self.Num["8"] =	CResStation:GetImage( 'shenbing8.png' );
			self.Num["9"] =	CResStation:GetImage( 'shenbing9.png' );
			self.Num[","] =	CResStation:GetImage( 'shenbingbaojidouhao.png' );
			self.Num["shandian"] =	CResStation:GetImage( 'shenbingbaojishandian.png' );
		end
	};
	[1021] =					--卓越一击
	{
		PfxName ="v_baoji.pfx";--对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["down"] = CResStation:GetImage( "zhuoyue.png" );
			self.Num["0"] =	CResStation:GetImage( 'zhuoyue0.png' );
			self.Num["1"] =	CResStation:GetImage( 'zhuoyue1.png' );
			self.Num["2"] =	CResStation:GetImage( 'zhuoyue2.png' );
			self.Num["3"] =	CResStation:GetImage( 'zhuoyue3.png' );
			self.Num["4"] =	CResStation:GetImage( 'zhuoyue4.png' );
			self.Num["5"] =	CResStation:GetImage( 'zhuoyue5.png' );
			self.Num["6"] =	CResStation:GetImage( 'zhuoyue6.png' );
			self.Num["7"] =	CResStation:GetImage( 'zhuoyue7.png' );
			self.Num["8"] =	CResStation:GetImage( 'zhuoyue8.png' );
			self.Num["9"] =	CResStation:GetImage( 'zhuoyue9.png' );
			self.Num[","] =	CResStation:GetImage( 'zhuoyuedouhao.png' );
			self.Num["shandian"] =	CResStation:GetImage( 'zhuoyueshandian.png' );
		end
	};

	[1022] =					--这个是伤害加深的跳字配置
	{
		PfxName ="v_beijishuzi.pfx"; --对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};

		NetNumFunc = function(self) 		
			self.Num["down"] = CResStation:GetImage( "beiji-.png" );
			self.Num["0"] =	CResStation:GetImage( 'beiji0.png' );
			self.Num["1"] =	CResStation:GetImage( 'beiji1.png' );
			self.Num["2"] =	CResStation:GetImage( 'beiji2.png' );
			self.Num["3"] =	CResStation:GetImage( 'beiji3.png' );
			self.Num["4"] =	CResStation:GetImage( 'beiji4.png' );
			self.Num["5"] =	CResStation:GetImage( 'beiji5.png' );
			self.Num["6"] =	CResStation:GetImage( 'beiji6.png' );
			self.Num["7"] =	CResStation:GetImage( 'beiji7.png' );
			self.Num["8"] =	CResStation:GetImage( 'beiji8.png' );
			self.Num["9"] =	CResStation:GetImage( 'beiji9.png' );
			self.Num[","] =	CResStation:GetImage( 'beijidouhao.png' );
			self.Num["sp"] = CResStation:GetImage( 'jingjieyazhi_shuzi.png' );
		end
	};

	[1023] =					--这个是伤害加深的暴击配置
	{
		PfxName ="v_baoji.pfx";--对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["crit"] = CResStation:GetImage( "baoji-.png" );
			self.Num["0"] =	CResStation:GetImage( 'baoji0.png' );
			self.Num["1"] =	CResStation:GetImage( 'baoji1.png' );
			self.Num["2"] =	CResStation:GetImage( 'baoji2.png' );
			self.Num["3"] =	CResStation:GetImage( 'baoji3.png' );
			self.Num["4"] =	CResStation:GetImage( 'baoji4.png' );
			self.Num["5"] =	CResStation:GetImage( 'baoji5.png' );
			self.Num["6"] =	CResStation:GetImage( 'baoji6.png' );
			self.Num["7"] =	CResStation:GetImage( 'baoji7.png' );
			self.Num["8"] =	CResStation:GetImage( 'baoji8.png' );
			self.Num["9"] =	CResStation:GetImage( 'baoji9.png' );
			self.Num[","] =	CResStation:GetImage( 'baojidouhao.png' );
			self.Num["shandian"] =	CResStation:GetImage( 'baojishandian.png' );
			self.Num["sp"] = CResStation:GetImage( 'jingjieyazhi-baoji.png' );
		end
	};

	[1024] =					--无视一击
	{
		PfxName ="v_baoji.pfx";--对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["down"] = CResStation:GetImage( "wushi.png" );
			self.Num["0"] =	CResStation:GetImage( 'wushi0.png' );
			self.Num["1"] =	CResStation:GetImage( 'wushi1.png' );
			self.Num["2"] =	CResStation:GetImage( 'wushi2.png' );
			self.Num["3"] =	CResStation:GetImage( 'wushi3.png' );
			self.Num["4"] =	CResStation:GetImage( 'wushi4.png' );
			self.Num["5"] =	CResStation:GetImage( 'wushi5.png' );
			self.Num["6"] =	CResStation:GetImage( 'wushi6.png' );
			self.Num["7"] =	CResStation:GetImage( 'wushi7.png' );
			self.Num["8"] =	CResStation:GetImage( 'wushi8.png' );
			self.Num["9"] =	CResStation:GetImage( 'wushi9.png' );
		end
	};

	[1025] =					--神灵攻击
	{
		PfxName ="v_baoji.pfx";--对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["down"] = CResStation:GetImage( "shenling.png" );
			self.Num["0"] =	CResStation:GetImage( 'shenling0.png' );
			self.Num["1"] =	CResStation:GetImage( 'shenling1.png' );
			self.Num["2"] =	CResStation:GetImage( 'shenling2.png' );
			self.Num["3"] =	CResStation:GetImage( 'shenling3.png' );
			self.Num["4"] =	CResStation:GetImage( 'shenling4.png' );
			self.Num["5"] =	CResStation:GetImage( 'shenling5.png' );
			self.Num["6"] =	CResStation:GetImage( 'shenling6.png' );
			self.Num["7"] =	CResStation:GetImage( 'shenling7.png' );
			self.Num["8"] =	CResStation:GetImage( 'shenling8.png' );
			self.Num["9"] =	CResStation:GetImage( 'shenling9.png' );
		end
	};
	
	[1026] =					--神灵攻击
	{
		PfxName ="v_baoji.pfx";--对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self) 		
			self.Num["down"] = CResStation:GetImage( "shenling.png" );
			self.Num["0"] =	CResStation:GetImage( 'shenling0.png' );
			self.Num["1"] =	CResStation:GetImage( 'shenling1.png' );
			self.Num["2"] =	CResStation:GetImage( 'shenling2.png' );
			self.Num["3"] =	CResStation:GetImage( 'shenling3.png' );
			self.Num["4"] =	CResStation:GetImage( 'shenling4.png' );
			self.Num["5"] =	CResStation:GetImage( 'shenling5.png' );
			self.Num["6"] =	CResStation:GetImage( 'shenling6.png' );
			self.Num["7"] =	CResStation:GetImage( 'shenling7.png' );
			self.Num["8"] =	CResStation:GetImage( 'shenling8.png' );
			self.Num["9"] =	CResStation:GetImage( 'shenling9.png' );
		end
	};
	
	[1027] =					--天神攻击
	{
		PfxName ="v_baoji.pfx";--对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self)
			self.Num["crit"] = CResStation:GetImage( "tianshenbaoji.png" );
			self.Num["down"] = CResStation:GetImage( "tianshenshanghai.png" );
			self.Num["0"] =	CResStation:GetImage( 'wushi0.png' );
			self.Num["1"] =	CResStation:GetImage( 'wushi1.png' );
			self.Num["2"] =	CResStation:GetImage( 'wushi2.png' );
			self.Num["3"] =	CResStation:GetImage( 'wushi3.png' );
			self.Num["4"] =	CResStation:GetImage( 'wushi4.png' );
			self.Num["5"] =	CResStation:GetImage( 'wushi5.png' );
			self.Num["6"] =	CResStation:GetImage( 'wushi6.png' );
			self.Num["7"] =	CResStation:GetImage( 'wushi7.png' );
			self.Num["8"] =	CResStation:GetImage( 'wushi8.png' );
			self.Num["9"] =	CResStation:GetImage( 'wushi9.png' );
		end
	};
	[1029] =					--法宝技能普通伤害
	{
		PfxName ="v_beijishuzi.pfx"; --对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self)
			self.Num["down"] = CResStation:GetImage( "fabao.png" );
			self.Num["0"] =	CResStation:GetImage( 'fabao0.png' );
			self.Num["1"] =	CResStation:GetImage( 'fabao1.png' );
			self.Num["2"] =	CResStation:GetImage( 'fabao2.png' );
			self.Num["3"] =	CResStation:GetImage( 'fabao3.png' );
			self.Num["4"] =	CResStation:GetImage( 'fabao4.png' );
			self.Num["5"] =	CResStation:GetImage( 'fabao5.png' );
			self.Num["6"] =	CResStation:GetImage( 'fabao6.png' );
			self.Num["7"] =	CResStation:GetImage( 'fabao7.png' );
			self.Num["8"] =	CResStation:GetImage( 'fabao8.png' );
			self.Num["9"] =	CResStation:GetImage( 'fabao9.png' );
			self.Num[","] =	CResStation:GetImage( 'shenbingbeijidouhao.png' );
		end
	};

	[1028] =					--法宝技能暴击伤害
	{
		PfxName ="v_baoji.pfx";--对应的轨迹特效名
		BindPos = 'bip01 spine1';--启动的绑点，人用这个
		Num={};
		NetNumFunc = function(self)
			self.Num["crit"] = CResStation:GetImage( "fabao.png" );
			self.Num["0"] =	CResStation:GetImage( 'fabao0.png' );
			self.Num["1"] =	CResStation:GetImage( 'fabao1.png' );
			self.Num["2"] =	CResStation:GetImage( 'fabao2.png' );
			self.Num["3"] =	CResStation:GetImage( 'fabao3.png' );
			self.Num["4"] =	CResStation:GetImage( 'fabao4.png' );
			self.Num["5"] =	CResStation:GetImage( 'fabao5.png' );
			self.Num["6"] =	CResStation:GetImage( 'fabao6.png' );
			self.Num["7"] =	CResStation:GetImage( 'fabao7.png' );
			self.Num["8"] =	CResStation:GetImage( 'fabao8.png' );
			self.Num["9"] =	CResStation:GetImage( 'fabao9.png' );
			self.Num[","] =	CResStation:GetImage( 'shenbingbaojidouhao.png' );
			self.Num["shandian"] =	CResStation:GetImage( 'shenbingbaojishandian.png' );
		end
	};
}

