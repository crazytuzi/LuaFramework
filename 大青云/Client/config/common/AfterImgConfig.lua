_G.AfterImgConfig =
{
	[11013] = 
	{ 
		dwAfterImgCount = 2; --技能数量，必须由系统控制
		fAfterImgDelay = 0.05;  --动作延迟 
		fAfterImgPos = 1.2;	--位移间隔
		AfterAddColor = 0xFF000000/(2+1); --残影每次递增的透明度 = 不透明（0xFF000000）/dwAfterImgCount+2
		AfterBaseColor = 0x00ffffff
	};
	[11015] = 
	{ 
		dwAfterImgCount = 2; --技能数量，必须由系统控制
		fAfterImgDelay = 0.1;  --动作延迟 
		fAfterImgPos = 0.05;	--位移间隔
		AfterAddColor = 0xFF000000/(2+2); --残影每次递增的透明度 = 不透明（0xFF000000）/dwAfterImgCount+2
		AfterBaseColor = 0x11000000
	};
	[21005] = 
	{ 
		dwAfterImgCount = 1; --技能数量，必须由系统控制
		fAfterImgDelay = 0.1;  --动作延迟 
		fAfterImgPos = 0.2;	--位移间隔
		AfterAddColor = 0xFF000000/(1+2); --残影每次递增的透明度 = 不透明（0xFF000000）/dwAfterImgCount+2
		AfterBaseColor = 0x11000000
	};
	[1002] = 
	{ 
		dwAfterImgCount = 4; --技能数量，必须由系统控制
		fAfterImgDelay = 0.15;  --动作延迟 
		fAfterImgPos = 0.25;	--位移间隔
		AfterAddColor = 0xFF000000/(4+2); --残影每次递增的透明度 = 不透明（0xFF000000）/dwAfterImgCount+2
		AfterBaseColor = 0x1100ff00
	}
}