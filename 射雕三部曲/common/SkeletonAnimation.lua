--[[
    文件名：SkeletonAnimation
	描述：骨骼动画,封装了创建、执行、回调、速度等参数
	创建人：luoyibo
	创建时间：2015.04.23
-- ]]

SkeletonAnimation = {}
require("common.SkeletonCache")
--创建骨骼
--[[
	params:
		file 			文件名(必须).特别说明：文件名不带路径。如"hero_lu_M1"
		parent 			父节点
		position 		坐标
		position3D		3d坐标
		scale 			缩放
		zorder 			排序
		--以下一组回调会监视当前人物的所有回调
		startListener 	动作开始回调。与循环次数无关，一个动作只会执行一次。
		endListener 	动作结束回调。所有动作执行完成，停下来的时候，才会调用end
		completeListener 动作完成回调。每个动作完成一次，就会调用一次。
		eventListener 	事件回调
		async 			异步回调（函数）
						创建spine动画的时候，最好把parent作为参数传入创建函数。如果不行的，需要在完成回调里自行判断父节点是否可用(if not tolua.isnull(parent) then)
		loadEvent 		是否加载事件
	return:
		skeleton 		骨骼对象
--]]
function SkeletonAnimation.create(params)
	if not params.file then
		dump("-----错误:没有文件路径")
		return nil
	end
	local jsonFile = params.file..".skel"
	local atlasFile = params.file..".atlas"

	local function setup( skeleton )
		--添加父子关系
		if params.parent then
			params.parent:addChild(skeleton , params.zorder or 0)
		end
		--设置坐标
		if params.position then
			skeleton:setPosition(params.position)
		end
		--设置3d坐标
		if params.position3D then
			skeleton:setPosition3D(params.position3D)
		end
		--设置缩放
		if params.scale then
			skeleton:setScale(params.scale)
		end

		-- 加载外部事件
		if params.loadEvent then
		    skeleton:clearEvent()
		    if cc.FileUtils:getInstance():isFileExist(params.file .. ".event") then
		        local eventPath = cc.FileUtils:getInstance():fullPathForFilename(params.file .. ".event")
		        skeleton:loadEvent(eventPath)
		    else
		        local defaultEventPath = cc.FileUtils:getInstance():fullPathForFilename("hero_default.event")
		        skeleton:loadEvent(defaultEventPath)
		    end
		end

		-- --注册全局函数
		if params.startListener then
			params.startListener(skeleton)
		end
		if params.endListener then
			skeleton:setEndListener(params.endListener)
		end
		if params.completeListener then
			skeleton:setCompleteListener(params.completeListener)
		end
		if params.eventListener then
			skeleton:setEventListener(params.eventListener)
		end
	end
	if params.async then
		SkeletonCache:getDataAsync(jsonFile,atlasFile,1--[[形象大小--]] , function( data )
			if (not params.parent) or (not tolua.isnull(params.parent)) then
				local skeleton = sp.SkeletonExtend:createWithData(data)
				setup(skeleton)
				params.async(skeleton)
			end
		end)
	else
		local skeleton = SkeletonCache:createWithBinary(jsonFile,atlasFile,1--[[形象大小--]])
		setup(skeleton)
		return skeleton
	end
end

--刷新动画参数
--[[
	params:
		skeleton 		骨骼(必须)
		speed 			速度
		skin 			皮肤
	return:
		NULL
--]]
function SkeletonAnimation.update(params)
	if not params.skeleton then
		error("-----错误:找不到骨骼")
		return
	end
	--设置皮肤
	if params.skin then
		if not params.skeleton:setSkin(params.skin) then
			params.skeleton:setSkin("default")
		end
		params.skeleton:setToSetupPose()
	end
	--设置动画播放速度
	if params.speed then
		params.skeleton:setTimeScale(params.speed)
	end
end

--执行骨骼动作
--[[
	params:
		skeleton 		骨骼对象(必须)
		action 			动作(必须)
		loop 			是否循环
		startListener 	动作开始回调,
		endListener 	动作结束回调
		completeListener 动作完成回调
		eventListener 	事件回调
		trackIndex 		动作序列。值越大，显示优先级越高。不同轨道相互不会影响。
	return:
		NULL
--]]
function SkeletonAnimation.action(params)
	if not params.skeleton or not params.action or type(params.action) ~= "string" then
		error("-----错误:找不到骨骼或没有动作")
		return
	end

	if not params.delay then
		--params.skeleton:clearTracks()
		-- params.skeleton:setToSetupPose()
		params.skeleton:setSlotsToSetupPose()
	end


	--设置动画
	local trackEntry
	if params.delay then
		trackEntry = params.skeleton:addAnimation(params.trackIndex or 0 ,  params.action , params.loop or false , params.delay)
	else
		trackEntry = params.skeleton:setAnimation(params.trackIndex or 0 ,  params.action , params.loop or false)
	end

	if trackEntry == nil then
		return
	end

	--注册回调
	if params.startListener then
		params.skeleton:setTrackStartListener(trackEntry , function(trackIndex)
			params.startListener({trackIndex = trackIndex})
		end)
	end

	if params.endListener then
		params.skeleton:setTrackEndListener(trackEntry , function(trackIndex)
			params.endListener({trackIndex = trackIndex})
		end)
	end

	if params.completeListener then
		params.skeleton:setTrackCompleteListener(trackEntry , function(trackIndex, loopCount)
			params.completeListener({trackIndex = trackIndex, loopCount = loopCount})
		end)
	end

	if params.eventListener then
		params.skeleton:setTrackEventListener(trackEntry , function(p)
			params.eventListener(p)
		end)
	end
end

--设置动作混合
--混合只会发生在统一track上。把上一个动作的最好duration时长和下一个动作开始的duration时长混合
--[[
	params:
		skeleton 		骨骼
		fromAnimation	从X动作结束
		toAnimation		从X动作开始
		duration		混合时长
	return:
		NULL
]]
function SkeletonAnimation.mix(params)
	if not params.skeleton then
		error("-----错误:找不到骨骼或没有动作")
		return
	end
	params.skeleton:setMix(params.fromAnimation, params.toAnimation, params.duration)
end

--倒序播放动作
--[[
	params:
		skeleton 		骨骼对象(必须)
		speed 			播放速度
	return:
		NULL
--]]
function SkeletonAnimation.pourPlay(params)
	params.skeleton:setTimePercent(100)
	params.skeleton:setTimeScale(params.speed and -params.speed or -1)
end

return SkeletonAnimation
