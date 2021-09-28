--[[
    文件名: MeetJinyongLayer.lua
	描述: 知识问答
	创建人: xufan
	创建时间: 2016.10.11
--]]

--[[
    params =  {
        meetInfo   :    奇遇数据
        showMeetId :    选中界面ID
        selIndex   :    选中页索引
    }
]]

local MeetJinyongLayer = class("MeetJinyongLayer", function()
    return display.newLayer()
end)

--构造
function MeetJinyongLayer:ctor(params)
	--当前奇遇数据
    self.mMeetInfo = params.meetInfo[params.selIndex]
    -- 选中界面ID
	self.mSelIndex = params.selIndex
	-- 答案控件(checkBox)列表
    self.answerList = {}
	self:initUI()	--初始化
    self:requestGetMeetQa() --请求数据
end

--初始化
function MeetJinyongLayer:initUI()
	-- 父节点
	self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 背景图
    local bgSprite = ui.newSprite("cdjh_20.jpg")
    bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(320,568)
    self.mParentLayer:addChild(bgSprite)

    -- 顶部提示
    -- 提示背景
    local hintBg = ui.newScale9Sprite("c_25.png", cc.size(550, 60))
    hintBg:setPosition(320, 950)
    bgSprite:addChild(hintBg)
    -- 提示label
    local hintLabel = ui.newLabel({
    	text = TR("猜灯谜，答谜题，回答问题获得丰富奖励～"),
    	size = 24,
    	color = Enums.Color.eNormalWhite,
    	outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
    	align = ui.TEXT_ALIGN_CENTER,
    	})
    hintLabel:setPosition(hintBg:getContentSize().width*0.5, hintBg:getContentSize().height*0.5)
    hintBg:addChild(hintLabel)

    -- 人物
    local heroSprite = ui.newSprite("cdjh_59.png")
    heroSprite:setPosition(320, 600)
    bgSprite:addChild(heroSprite)

    -- 对话框
    local dialogSprite = ui.newScale9Sprite("cdjh_54.png", cc.size(200, 100))
    dialogSprite:setAnchorPoint(cc.p(0, 0.5))
    dialogSprite:setPosition(20, 820)
    bgSprite:addChild(dialogSprite)
    -- 对话label
    local dialogLabel = ui.newLabel({
    	text = TR("少年，看题～"),
    	size = 24,
    	color = Enums.Color.eNormalWhite,
    	-- outlineColor = Enums.Color.eOutlineColor,
    	align = ui.TEXT_ALIGN_CENTER,
    	})
    dialogLabel:setPosition(dialogSprite:getContentSize().width*0.5, dialogSprite:getContentSize().height*0.55)
    dialogSprite:addChild(dialogLabel)

    -- 创建问答区
    self:createQAArea()
end

--[[
	描述：创建问答区
]]
local answerPostion = {
	[1] = cc.p(180, 430),
	[2] = cc.p(450, 430),
	[3] = cc.p(180, 350),
	[4] = cc.p(450, 350),
}
function MeetJinyongLayer:createQAArea()
	-- 背景
	local bgSprite = ui.newSprite("cdjh_8.png")
	bgSprite:setPosition(320, 350)
	self.mParentLayer:addChild(bgSprite)
	-- 背景大小
	local bgSize = bgSprite:getContentSize()

	-- 问题label
	local questionLabel = ui.newLabel({
		text = TR(""),
		color = Enums.Color.eBlack,
		size = 22,
		dimensions = cc.size(bgSize.width*0.8, 0),
		x = 50,
		y = bgSize.height*0.82
		})
	questionLabel:setAnchorPoint(cc.p(0, 0.5))
	bgSprite:addChild(questionLabel)
	self.mQusetion = questionLabel

	-- 答案
	for i = 1, 4 do
		self.answerList[i] = self:createAnswerBox(i)
	end

	-- 正确奖励
	self.rightReward = CardNode.createCardNode({
			resourceTypeSub = ResourcetypeSub.eDiamond,
			modelId = 0,
			num = 50,
			cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
		})
	self.rightReward:setPosition(bgSize.width*0.3-2, bgSize.height*0.15+5)
	bgSprite:addChild(self.rightReward)
	-- 错误奖励
	self.wrongReward = CardNode.createCardNode({
			resourceTypeSub = ResourcetypeSub.eDiamond,
			modelId = 0,
			num = 25,
			cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
		})
	self.wrongReward:setPosition(bgSize.width*0.7-5, bgSize.height*0.15+5)
	bgSprite:addChild(self.wrongReward)
end

--[[
	描述：创建答案ui
	参数：index	第index个答案
]]
function MeetJinyongLayer:createAnswerBox(index)
	-- 答案背景图
	local answerBgSize = cc.size(228, 50)
	local answerBg = ui.newScale9Sprite("cdjh_9.png", answerBgSize)
	answerBg:setPosition(answerPostion[index])
	self.mParentLayer:addChild(answerBg, 1)
	-- 答案复选框
	local answerBox = ui.newCheckbox({
		normalImage = "c_60.png",
		selectImage = "c_61.png",
		text = TR(""),
		textColor = Enums.Color.eBlack,
		callback = function ()
			self:requestMeetQaOp(index)
		end
		})
	answerBox:setPosition(answerBgSize.width*0.5, answerBgSize.height*0.5)
	answerBg:addChild(answerBox)

	return answerBox
end


--刷新UI
function MeetJinyongLayer:refreshUI()
    local info = QuickexpMeetQaModel.items[self.mData.TargetId]
    --刷新题目
    self.mQusetion:setString(info.question)

    --刷新答案选项
    --如果之前已经生成过一次答案位置 则不再进行重置
    if not self.mMeetInfo.answerIndex then
        local tempConfig = {1, 2, 3 ,4}
        --保存答案位置 下次切换回来还可以保持答案的位置 但是退出奇遇再进奇遇会重置
        self.mMeetInfo.answerIndex = {}
        --抽取正确答案位置
        self.mOkAnswerIndex = math.random(1, #tempConfig)
        table.remove(tempConfig, self.mOkAnswerIndex)
        --显示正确答案
        self.answerList[self.mOkAnswerIndex]:setString(info.answer)
        self.mMeetInfo.answerIndex["answer"] = self.mOkAnswerIndex --保存答案位置
        --刷新错误答案
        local tempNum = 1
        for index, item in ipairs(tempConfig) do
            self.answerList[item]:setString(info["wrong"..tempNum])
            self.mMeetInfo.answerIndex["wrong"..tempNum] = item --保存答案位置
            tempNum = tempNum + 1
        end
    else
        --配置之前保存好的答案位置
        for k, v in pairs(self.mMeetInfo.answerIndex) do
            self.answerList[v]:setString(info[k])
            --单独保存正确答案下标用于请求服务器判断
            if k == "answer" then
                self.mOkAnswerIndex = v
            end
        end
    end

    --创建答对奖励卡
    local tempList = Utility.analysisStrResList(info.rightReward)
    self.rightReward:setCardData(tempList[1])
    -- local card = CardNode.createCardNode(tempList[1])
    -- card:setPosition(230, self.mRewardBg:getContentSize().height / 2 - 40)
    -- card:setScale(0.85)
    -- self.mRewardBg:addChild(card)
    -- self.mOkCrad = card

    --创建答错奖励卡
    tempList = Utility.analysisStrResList(info.wrongReward)
    self.wrongReward:setCardData(tempList[1])
    -- local card1 = CardNode.createCardNode(tempList[1])
    -- card1:setPosition(510, self.mRewardBg:getContentSize().height / 2 - 40)
    -- card1:setScale(0.85)
    -- self.mRewardBg:addChild(card1)
    -- self.mWrongCrad = card1

    --当前奇遇已经完成
    if self.mMeetInfo.IsDone then
        self:meetIsDone()
        return
    end

    for index, item in ipairs(self.answerList) do
        item:setTouchEnabled(true)
    end
end

--奇遇结束
function MeetJinyongLayer:meetIsDone(isOk)
    self.mMeetInfo.IsDone = true
    self.mMeetInfo.redDotSprite:setVisible(false)
    -- self.mHadGet:setVisible(true)
    -- self.mHadGet:setPosition(self.mMeetInfo.isOk and cc.p(110, self.mRewardBg:getContentSize().height / 2 - 50) or cc.p(390, self.mRewardBg:getContentSize().height / 2 - 50))
    for index, item in ipairs(self.answerList) do
        item:setTouchEnabled(false)
    end

    self.answerList[self.mOkAnswerIndex]:setCheckState(true)

    if self.mOkAnswerIndex ~= self.mMeetInfo.selectIndex then
        self.answerList[self.mMeetInfo.selectIndex].button:loadTextures("c_136.png", "c_136.png")
    end
end

-------------------服务器请求相关----------------------

--获取当前答题信息
function MeetJinyongLayer:requestGetMeetQa()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "QuickExp",
        methodName = "GetMeetQaInfo",
        svrMethodData = {self.mMeetInfo.Id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mData = response.Value
            --dump(response.Value, "获取答题信息")
            self:refreshUI()
        end
    })
end

--回答问题
function MeetJinyongLayer:requestMeetQaOp(index)
    self.mMeetInfo.selectIndex = index --保存选择的答案 下次切换回来再次绘制
    local isOk = (index == self.mOkAnswerIndex) --判断回答是否正确
    local tips = isOk and "cdjh_63.png" or "cdjh_64.png"
    local tipsColor = isOk and Enums.Color.eSkyBlue or Enums.Color.eRed
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "QuickExp",
        methodName = "MeetQaOp",
        svrMethodData = {self.mMeetInfo.Id, isOk},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response.Value, "获取答题信息")
            self.mMeetInfo.isOk = isOk
            self:meetIsDone()
            -- ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            --添加自定义提示
            local custom = {
                [1] = {
                    ["node"] = ui.newSprite(tips),
                    ["position"] = cc.p(320, 180)
                }
            }
            LayerManager.addLayer({
                name = "commonLayer.FlashDropLayer", 
                data = {baseDrop = response.Value.BaseGetGameResourceList, customAdd = custom}, 
                cleanUp = false, 
                zOrder = Enums.ZOrderType.eNewbieGuide + 1}
            )
        end
    })
end

return MeetJinyongLayer
