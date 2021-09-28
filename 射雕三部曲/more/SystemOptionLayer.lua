--[[
	文件名：SystemOptionLayer.lua
	描述：更多－－设置
	创建人：yanxingrui
	创建时间： 2016.6.2
    修改人：wukun
    修改时间： 2016.9.14
--]]

local SystemOptionLayer = class("SystemOptionLayer", function(params)
	return display.newLayer()
end)

function SystemOptionLayer:ctor()
	-- 初始化页面
	self:initUI()
end

-- 初始化页面
function SystemOptionLayer:initUI()
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 初始化localdata数据
    local restoreData = LocalData:getSetting()
    self.mMusicCount = restoreData.musicVolume
    self.mMusicEnabled = restoreData.musicEnabled
    self.mSoundCount = restoreData.effectVolume
    self.mSoundEnabled = restoreData.effectEnabled
    self.mPushEnabled = restoreData.pushEnabled

    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("游戏设置"),
        bgSize = cc.size(598, 474),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹窗控件信息
    self.mBgSprite = bgLayer.mBgSprite
    self.mBgSize = bgLayer.mBgSprite:getContentSize()

    --灰色背景图
    local darkBgSprite = ui.newScale9Sprite("c_17.png",cc.size(536, 300))
    darkBgSprite:setPosition(self.mBgSize.width / 2, self.mBgSize.height / 2 + 15)
    self.mBgSprite:addChild(darkBgSprite)

    -- 设置消息推送的checkbox
    self.mInfoCheckbox = ui.newCheckbox({
    	normalImage = "c_60.png",
    	selectImage = "c_61.png",
    	isRevert = true,
    	text = TR("消息推送"),
    	textColor = cc.c3b(0x46, 0x22, 0x0d),
    	callback = function(state)
    		if state == true then
    			LocalData:setPushEnabled(true)
    		else
    			LocalData:setPushEnabled(false)
    		end
    	end
    })
    self.mInfoCheckbox:setCheckState(self.mPushEnabled)
    self.mInfoCheckbox:setPosition(118, 330)
    self.mBgSprite:addChild(self.mInfoCheckbox)

    -- 设置关闭音乐的checkbox
    self.mCloseMusicCheckbox = ui.newCheckbox({
    	normalImage = "c_60.png",
    	selectImage = "c_61.png",
    	isRevert = true,
    	text = TR("关闭音乐"),
    	textColor = cc.c3b(0x46, 0x22, 0x0d),
    	callback = function(state)
    		if state == true then
    			LocalData:setMusicEnabled(false)
    		else
    			LocalData:setMusicEnabled(true)
    		end
    	end
    })
    self.mCloseMusicCheckbox:setCheckState(not self.mMusicEnabled)
    self.mCloseMusicCheckbox:setPosition(288, 330)
    self.mBgSprite:addChild(self.mCloseMusicCheckbox)

    -- 设置关闭音效的checkbox
    self.mCloseSoundCheckbox = ui.newCheckbox({
    	normalImage = "c_60.png",
    	selectImage = "c_61.png",
    	isRevert = true,
    	text = TR("关闭音效"),
    	textColor = cc.c3b(0x46, 0x22, 0x0d),
    	callback = function(state)
    		if state == true then
    			LocalData:setEffectEnabled(false)
    		else
    			LocalData:setEffectEnabled(true)
    		end
    	end
    })
    self.mCloseSoundCheckbox:setCheckState(not self.mSoundEnabled)
    self.mCloseSoundCheckbox:setPosition(469, 330)
    self.mBgSprite:addChild(self.mCloseSoundCheckbox)

    -- 创建配音选择
    self:createSoundSelect()

    -- 音乐进度条
    local musicLabel = ui.newLabel({
        text = TR("音乐"),
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    musicLabel:setPosition(95, 257)
    self.mBgSprite:addChild(musicLabel)

    --添加"减"按钮
    local musicReduceBtn = ui.newButton({
        normalImage = "gd_28.png",
        position = cc.p(155, 257),
        clickAction = function()
            if self.mMusicCount > 0 then
            	self.mMusicCount = self.mMusicCount - 20
            end
            self.mMusicProgress:setCurrValue(self.mMusicCount)
            LocalData:setMusicVolume(self.mMusicCount)
        end
    })
    self.mBgSprite:addChild(musicReduceBtn)

    -- 添加进度条
    self.mMusicProgress = require("common.ProgressBar"):create({
    	bgImage = "gd_12.png",
    	barImage = "gd_11.png",
    	currValue = self.mMusicCount,
    	maxValue = 100,
    })
    -- self.mMusicProgress:setScale(0.8)
    self.mMusicProgress:setCurrValue(self.mMusicCount)
    self.mMusicProgress:setPosition(335, 257)
    self.mBgSprite:addChild(self.mMusicProgress)

    --添加"加"按钮
    local musicAddBtn = ui.newButton({
        normalImage = "gd_27.png",
        position = cc.p(505, 257),
        clickAction = function()
            if self.mMusicCount < 100 then
            	self.mMusicCount = self.mMusicCount + 20
            end
            self.mMusicProgress:setCurrValue(self.mMusicCount)
            LocalData:setMusicVolume(self.mMusicCount)
        end
    })
    self.mBgSprite:addChild(musicAddBtn)

    -- 音效进度条
    local soundLabel = ui.newLabel({
        text = TR("音效"),
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    soundLabel:setPosition(95, 195)
    self.mBgSprite:addChild(soundLabel)

    --添加"减"按钮
    local soundReduceBtn = ui.newButton({
        normalImage = "gd_28.png",
        position = cc.p(155, 195),
        clickAction = function()
            if self.mSoundCount > 0 then
            	self.mSoundCount = self.mSoundCount - 20
            end
            self.mSoundProgress:setCurrValue(self.mSoundCount)
            LocalData:setEffectVolume(self.mSoundCount)
        end
    })
    self.mBgSprite:addChild(soundReduceBtn)

    -- 添加进度条
    self.mSoundProgress = require("common.ProgressBar"):create({
    	bgImage = "gd_12.png",
    	barImage = "gd_11.png",
    	currValue = self.mSoundCount,
    	maxValue = 100,
    })
    -- self.mSoundProgress:setScale(0.8)
    self.mSoundProgress:setCurrValue(self.mSoundCount)
    self.mSoundProgress:setPosition(335, 195)
    self.mBgSprite:addChild(self.mSoundProgress)

    --添加"加"按钮
    local soundAddBtn = ui.newButton({
        normalImage = "gd_27.png",
        position = cc.p(505, 195),
        clickAction = function()
            if self.mSoundCount < 100 then
            	self.mSoundCount = self.mSoundCount + 20
            end
            self.mSoundProgress:setCurrValue(self.mSoundCount)
            LocalData:setEffectVolume(self.mSoundCount)
        end
    })
    self.mBgSprite:addChild(soundAddBtn)

    -- 恢复默认按钮
    local revertBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("恢复默认"),
        size = 22,
        position = cc.p(299, 65),
        color = cc.c3b(0xff, 0xff, 0xff),
        clickAction = function(pSender)
            self.mInfoCheckbox:setCheckState(true)
            self.mCloseMusicCheckbox:setCheckState(false)
            self.mCloseSoundCheckbox:setCheckState(false)

            self.mMusicProgress:setCurrValue(80)
            self.mSoundProgress:setCurrValue(80)

            self.mMusicCount = 80
            self.mSoundCount = 80

            LocalData:setPushEnabled(true)
            LocalData:setMusicEnabled(true)
            LocalData:setMusicVolume(80)
            LocalData:setEffectEnabled(true)
            LocalData:setEffectVolume(80)
        end
    })
    self.mBgSprite:addChild(revertBtn)
end

function SystemOptionLayer:createSoundSelect()
    -- 提示文字
    local hintLabel = ui.newLabel({
            text = TR("配音选择"),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    hintLabel:setPosition(95, 140)
    self.mBgSprite:addChild(hintLabel)

    -- 音乐选择框列表
    self.mMusicCheckList = {}

    local checkTextList = {
        [1] = TR("国语"),
        [2] = TR("粤语"),
    }

    local count = 0
    for _, musicType in pairs(Enums.MusicType) do
        self.mMusicCheckList[musicType] = ui.newCheckbox({
            normalImage = "c_60.png",
            selectImage = "c_61.png",
            isRevert = true,
            text = checkTextList[musicType],
            textColor = cc.c3b(0x46, 0x22, 0x0d),
            callback = function(state)
                if state == true then
                    for key, checkbox in pairs(self.mMusicCheckList) do
                        checkbox:setCheckState(key == musicType)
                    end
                    Utility.setMusicType(musicType)
                else
                    self.mMusicCheckList[musicType]:setCheckState(true)
                end
            end
        })
        self.mMusicCheckList[musicType]:setPosition(250+150*count, 140)
        self.mBgSprite:addChild(self.mMusicCheckList[musicType])

        if musicType == Utility.getMusicType() then
            self.mMusicCheckList[musicType]:setCheckState(true)
        end

        count = count + 1
    end
    
end


return SystemOptionLayer
