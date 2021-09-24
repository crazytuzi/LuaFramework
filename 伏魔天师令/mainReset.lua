local ResetScene=classGc()

function ResetScene.mainReset(self)
	gcprint("\n \n \n \n")
	gcprint("*******************************************")
	gcprint("重启游戏 lua脚本 开始.....")
	gcprint("ResetScene============>>>>>")
	self.m_rootScene=cc.Scene:create()
	cc.Director:getInstance():popToRootScene()
	cc.Director:getInstance():replaceScene(self.m_rootScene)

	local winSize=cc.Director:getInstance():getWinSize()
	local mainColor=cc.c3b(255,255,255)
	self.m_contentLabel=_G.Util:CreateTraceLabel("更新完成,准备重启游戏",37,2,mainColor)
	self.m_contentLabel:setPosition(winSize.width*0.5,winSize.height*0.5)
	self.m_rootScene:addChild(self.m_contentLabel)

	gcprint("\n")
	gcprint("ResetScene============>>>>> unscheduleAll")
	_G.Scheduler:unAllschedule()
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_G.Util.m_logScheduler)

	local function delayFun()
		self:releaseResources()
	end
	self.m_rootScene:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(delayFun)))
end

function ResetScene.releaseResources(self)
	if _G.GLoginEffect~=nil then
		gcprint("\n")
		gcprint("ResetScene============>>>>> GLoginEffect:releaseResources")
        _G.GLoginEffect:releaseResources()
        _G.GLoginEffect=nil
    end

    self.m_contentLabel:setString("释放资源")
    gcprint("\n")
    gcprint("ResetScene============>>>>> deletePlistLongTime")
    local resList=Cfg.ResList[Cfg.UI_NeverRelease]
    for _,plist in pairs(resList) do
        gc.ResLoader:getInstance():deletePlistLongTime(plist)
    end
    gcprint("\n")
    gcprint("ResetScene============>>>>> removeSpriteFrames")
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
	gcprint("\n")
	gcprint("ResetScene============>>>>> removeUnusedTextures")
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    gcprint("\n")
    gcprint("ResetScene============>>>>> getCachedTextureInfo:")
    print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())

    local function delayFun()
		self:clearPreLuaFile()
	end
	self.m_rootScene:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(delayFun)))
end

function ResetScene.clearPreLuaFile(self)
    self.m_contentLabel:setString("清除脚本")
    gcprint("\n")
    gcprint("ResetScene============>>>>> do _G.package.loaded start...",tostring(collectgarbage("count")/1024).."MB")
    local loadedArray=_G.package.loaded
    local unloadArray=_G.GNoUnloadArray or {}
    for k,v in pairs(loadedArray) do
    	if unloadArray[k]~=true then
    		gcprint("====>>"..k)
    		loadedArray[k]=nil
    	end
    end
    loadedArray["main"]=nil
    gcprint("ResetScene============>>>>> do _G.package.loaded finish...",tostring(collectgarbage("count")/1024).."MB")

    local function delayFun()
		self:reloadAllZipData()
	end
	self.m_rootScene:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(delayFun)))
end

function ResetScene.reloadAllZipData(self)
	gcprint("\n")
	gcprint("ResetScene============>>>>> resetLuaZip")

	self.m_contentLabel:setString("重新加载脚本")
	gc.App:getInstance():resetLuaZip()
	if _G.SysInfo:getGcResType()==_G.Const.kResTypeZIP then
		gcprint("ResetScene============>>>>> resetResZip")
		gc.App:getInstance():resetResZip()
	end

	local function delayFun1()
		self.m_contentLabel:setString("重启游戏")
	end

	local function delayFun2()
		self:goMainLua()
	end
	self.m_rootScene:runAction(cc.Sequence:create(cc.DelayTime:create(1),
												  cc.CallFunc:create(delayFun1),
												  cc.DelayTime:create(1.5),
												  cc.CallFunc:create(delayFun2)))
end

function ResetScene.goMainLua(self)
	gcprint("重启游戏 lua脚本 结束.....")
	gcprint("*******************************************")
	gcprint("\n \n \n \n")
	gcprint("ResetScene============>>>>> goMainLua")

	_G.GRebootLuaScrite=true
	require("main")
end

return ResetScene





