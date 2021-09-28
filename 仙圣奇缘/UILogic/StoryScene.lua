--------------------------------------------------------------------------------------
-- 文件名:	StoryScene.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	战斗教学结束后过渡到创建角色目录
-- 应  用:  覆盖在 start game 上面 。等文字播放结束 。并且接收到随机名字响应后
---------------------------------------------------------------------------------------

StoryScene = class("StoryScene")
StoryScene.__index = StoryScene

local strStory = _T("死亡，即是重生，是轮回，亦是新的开始。")

function StoryScene:ctor()
	self.layer = nil
	self.wgtRoot = nil

	self.isFormBattleTeach = false

	self.Callback = nil
end


function StoryScene:InitAndRegister(gamelayer)
	if not self.isFormBattleTeach then return end

	self.wgtRoot = GUIReader:shareReader():widgetFromJsonFile("Game_StoryScene.json")
	self.wgtRoot:setTouchEnabled(true)
	gamelayer:addWidget(self.wgtRoot)

	self.wgtRoot:setCascadeOpacityEnabled(true)
	
	local Label_Dialogue = tolua.cast(self.wgtRoot:getChildByName("Label_Dialogue"),"Label")
	Label_Dialogue:setText(strStory)

	local action = CCFadeOut:create(0.1)
	local arrAct = CCArray:create()
    arrAct:addObject(action)

    local function funcCallback()
    	if self.wgtRoot then
    		self.wgtRoot:removeFromParent()
    	end

    	g_StoryScene = StoryScene.new()
    end

	arrAct:addObject(CCCallFuncN:create(funcCallback))
	local mActionSpa1 = CCSequence:create(arrAct)

	self.wgtRoot:runAction(mActionSpa1)
end


function StoryScene:OnExitBattleScene(Callback)
	self.Callback = Callback
	self.layer =  TouchGroup:create()
	self.layer:setTouchPriority(0)

	self.wgtRoot = GUIReader:shareReader():widgetFromJsonFile("Game_StoryScene.json")
	self.wgtRoot:setTouchEnabled(true)
	self.layer:addWidget(self.wgtRoot)

	local GameSence =  CCDirector:sharedDirector():getRunningScene()
	GameSence:addChild(self.layer, INT_MAX)

	self.wgtRoot:setCascadeOpacityEnabled(true)
	self.wgtRoot:setOpacity(0)
	self.wgtRoot:setColor(ccc3(255,255,255))

	local Label_Dialogue = tolua.cast(self.wgtRoot:getChildByName("Label_Dialogue"),"Label")
	Label_Dialogue:setText("")
	local nLen = string.len(strStory)
	cclog("============字符串长度============="..nLen)

	local TestLen = 0
	TestLen =  g_string_num(strStory) --字符串的有效个数

	---定时器打字
	local nSize = 0

	local function setWords()
		--循环定时器内部要判断一下界面是否已经不在了
		local nData = string.byte(strStory, nSize+1)
		--cclog("============字符串长度============="..nData)
		if not nData then
			return true
		end
		if nData < 128 then
			nSize = nSize + 1
		else
			nSize = nSize + 3
		end
		local strChar = string.sub(strStory, 1, nSize)
		--cclog("============字符串的值============="..strChar)
		Label_Dialogue:setText(strChar)
		if nSize >= nLen then
			--打字结束
			return true
		end
	end
	
	
	--1，界面界面淡出1秒后，执行打字机的函数，把对话内容1个个敲出来
	--2，对话敲完之后，才执行关闭界面的函数界面切换到选择角色列表
	
	local action = CCFadeIn:create(0.1)
	local arrAct = CCArray:create()
    arrAct:addObject(action)

    --添加打印回调action 队列
    for i = 1, TestLen do
    	local delay = CCDelayTime:create(0.1) --amount of seconds
    	local func = CCCallFuncN:create(setWords)
    	arrAct:addObject(delay)
    	arrAct:addObject(func)
    end

    local function funcCallback()
		if self.Callback then
			self.Callback()
			self.Callback = nil
		end
    end

    --文字播放完后的停顿
    local delay = CCDelayTime:create(1)
    arrAct:addObject(delay)

    --停顿后的回调播放
	arrAct:addObject(CCCallFuncN:create(funcCallback))

	local mActionSpa1 = CCSequence:create(arrAct)

	self.wgtRoot:runAction(mActionSpa1)
end


function StoryScene:SetFormBattleTeachTrue()
	self.isFormBattleTeach = true
end

function StoryScene:GetInStoryBattleTeach()
	return self.isFormBattleTeach
end


------------------------------------
g_StoryScene = StoryScene.new()