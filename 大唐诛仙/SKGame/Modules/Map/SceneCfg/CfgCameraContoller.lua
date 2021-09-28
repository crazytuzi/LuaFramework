local cfg = {
	isDebug = false, -- 开启调试
	CameraEmnu = { --BOSS（副本）摄像机配置
		cameraPosX = -0.47,		--摄像机位置xyz
		cameraPosY = 3.96,
		cameraPosZ = 1.51,
		fAngleX = 45, 		--镜头相对目标X轴旋转角度 	******* 默认值 39.00476
		fAngleY = 175,		--镜头相对目标Y轴旋转角度	******* 默认值 183.5721
		ctweenTime = 0.3,    --镜头切换时间
		fDis = 9.4,		--镜头离目标的距离	******* 默认值 10
		InnerRing = 7.5,	--内圈 安定范围	******* 默认值 5
		OuterRing = 12,	--外圈	******* 默认值 12
		rotX_paraI = 0,	--摄像机X轴偏移参数 1		******* 默认值 0.1
		rotX_paraII = 0.005, --摄像机X轴偏移参数 2	******* 默认值 0.003
		rotXMax = 28,		--最大值X偏移 1	******* 默认值 28
		scaleMinimum = 2.2,	--缩放最小比例	******* 默认值 0.6
		cameraScale_paraI = 1,	--摄像机缩放参数 1	******* 默认值 0.3
		cameraScale_paraII = 0.2,	--摄像机缩放参数 2	******* 默认值 0.2
		fTweenTime = 0.5,		--缓动时间	******* 默认值 0.5
		cTween_paraI = 2,	--摄像机缓动速度 参数 1	******* 默认值 0.3
		cTween_paraII = 0.01,	--摄像机缓动速度 参数 2	******* 默认值 0.2
		fNearDis = 0.001,		--距离小于此值时，直接放回跟随点	******* 默认值 0.001
		wQDefaultDis = 6,		--外圈默认距离	******* 默认值  5
		nQDefaultDis = 4,		--内圈默认距离	******* 默认值  9.4
		wQMaxDis = 6.78,			--外圈最大距离	******* 默认值	6.78

		modelDisappearDistance = 1000,
		headUIDisappearDistance = 1000
	},

	
	
	
	
}
return cfg