--[[
	文件名:ZhenjueStepUpLayer.lua
	描述：内功心法进阶页面
	创建人: peiyaoqiang
	创建时间: 2018.01.23
--]]

local ZhenjueStepUpLayer = class("ZhenjueStepUpLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 128))
end)

--[[
-- 参数 params 中各项为：
	{
		zhenjueId: 内功心法的ID
	}
]]
function ZhenjueStepUpLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})
	
	-- 处理参数
	self.mZhenjueId = params.zhenjueId
	self.mRefreshFunc = params.refreshFunc
	
	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

    -- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
    })
    self:addChild(tempLayer)

	-- 初始化页面控件
	self:initUI()
	self:refreshUI()
end

-- 初始化页面控件
function ZhenjueStepUpLayer:initUI()
	-- 关闭按钮
	local btnClose = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	btnClose:setPosition(cc.p(585, 980))
	self.mParentLayer:addChild(btnClose, 1)

	-- 规则按钮
	local btnRule = ui.newButton({
		normalImage = "c_72.png",
		clickAction = function()
			local rulesData = {
				TR("1.内功进阶会增加该内功的基础属性和基础洗炼上限"),
                TR("2.内功进阶需要消耗同名内功和特殊道具"),
                TR("3.特殊道具可以通过参加运营活动得到"),
                TR("4.橙色以下的内功无法进阶"),
            }
            MsgBoxLayer.addRuleHintLayer(TR("规则"), rulesData)
		end
	})
	btnRule:setPosition(55, 980)
	self.mParentLayer:addChild(btnRule, 1)

	-- 书卷的背景图
	local bookBgSprite = ui.newSprite("ng_20.png")
	bookBgSprite:setPosition(320, 650)
	self.mParentLayer:addChild(bookBgSprite)
	self.bookBgSprite = bookBgSprite
	self.bookBgSprite.drawOneLine = function (target, beginPos, endPos, isRedColor)
		local disv = cc.p(beginPos.x - endPos.x, beginPos.y - endPos.y)
	    local length = math.sqrt(disv.x * disv.x + disv.y * disv.y)
	    local angle = math.atan(disv.x / disv.y)
	    local calcAngle = (beginPos.y < endPos.y) and ((angle * 180) / math.pi) or ((angle * 180) / math.pi + 180)
	    
	    local sprite = ui.newScale9Sprite(isRedColor and "wgcw_26.png" or "wgcw_07.png", cc.size(length, 4))
	    sprite:setRotation(calcAngle - 90)
	    sprite:setAnchorPoint(cc.p(0, 0.5))
	    sprite:setPosition(beginPos)
	    target:addChild(sprite)
	end

	-- 底部信息栏背景
	local infoBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 375))
	infoBgSprite:setPosition(320, 0)
	infoBgSprite:setAnchorPoint(cc.p(0.5, 0))
	self.mParentLayer:addChild(infoBgSprite)
	self.infoBgSprite = infoBgSprite
	self.infoBgSprite.showConsumeRes = function (target, resList)
		if (resList == nil) then
			return
		end
		local tempBg1Sprite = ui.newScale9Sprite("c_17.png", cc.size(330, 140))
	    tempBg1Sprite:setPosition(240, 160)
	    target:addChild(tempBg1Sprite)

	    local tempBg2Sprite = ui.newScale9Sprite("c_18.png", cc.size(322, 132))
	    tempBg2Sprite:setPosition(240, 160)
	    target:addChild(tempBg2Sprite)

	    -- 显示消耗资源
	    local posList = {
	    	[1] = {cc.p(160, 78)},
	    	[2] = {cc.p(90, 78), cc.p(230, 78)},
		}
	    local tmpPosList = posList[#resList]
	    for i,v in ipairs(resList) do
	    	local tempCard, tmpShowAttrs = CardNode.createCardNode({
	    		resourceTypeSub = v.resourceTypeSub,
                modelId = v.modelId,
                num = v.num,
                cardShape = Enums.CardShape.eSquare,
                cardShowAttrs = {CardShowAttr.eNum, CardShowAttr.eBorder, CardShowAttr.eName},
                onClickCallback = function()
                    Utility.showResLackLayer(v.resourceTypeSub, v.modelId)
                end
	    	})
            tempCard:setPosition(tmpPosList[i])
            tempBg2Sprite:addChild(tempCard)

            -- 显示当前拥有数值
            local text = Utility.numberWithUnit(v.ownNum, 0).."/"..Utility.numberWithUnit(v.num, 0)
            tmpShowAttrs[CardShowAttr.eNum].label:setString(((v.ownNum >= v.num) and Enums.Color.eGreenH or Enums.Color.eRedH) .. text)
	    end
	end
end

-- 刷新界面
function ZhenjueStepUpLayer:refreshUI()
	self.bookBgSprite:removeAllChildren()
	self.infoBgSprite:removeAllChildren()
	if (self.mZhenjueId == nil) then
		return
	end

	-- 重新读取内功信息
	local zhenjueInfo = ZhenjueObj:getZhenjue(self.mZhenjueId)
	local stepConfig = ZhenjueStepRelation.items[zhenjueInfo.ModelId]
	if (stepConfig == nil) then
		return
	end
	local zhenjueModel = ZhenjueModel.items[zhenjueInfo.ModelId]
	local currStep = zhenjueInfo.Step or 0
	local nextStep = currStep + 1
	local currConfig = stepConfig[currStep]
	local nextConfig = stepConfig[nextStep]
	if (currStep == 0) then
		currConfig = {stepAttrRAdd = 10000} 	-- 进阶为0的时候不增加基础属性
	end

	self.mFilter = {notInFormation = true, noStepUp = true, noExtraUp = true, excludeIdList = {self.mZhenjueId}}
	
	-- 显示名字
	local nameSprite = ui.newSprite(ZhenjueObj:getNameImgOfStep(zhenjueInfo.ModelId))
	nameSprite:setPosition(60, 185)
	self.bookBgSprite:addChild(nameSprite)

	-- 显示进阶指示图
	local stepImgList = {[0] = "ng_23.png", [1] = "ng_24.png", [2] = "ng_25.png", [3] = "ng_26.png", [4] = "ng_27.png", [5] = "ng_28.png", [6] = "ng_22.png"}
	local imgPosList = {cc.p(190, 190), cc.p(340, 40), cc.p(490, 190)}
	local showImgList = nil
	if (currStep == 0) then
		showImgList = {{showIndex = 0, isActive = true}, {showIndex = 1, isActive = false}, {showIndex = 2, isActive = false}}
	else
		showImgList = {{showIndex = (currStep-1), isActive = true}, {showIndex = currStep, isActive = true}, {showIndex = nextStep, isActive = false}}
	end
	local lastNodePos = nil
	for i,v in ipairs(showImgList) do
		-- 显示阶位图
		local stepPos = imgPosList[i]
		local stepSprite = ui.newSprite(stepImgList[v.showIndex])
		stepSprite:setAnchorPoint(cc.p(0.5, 0))
		stepSprite:setPosition(stepPos)
		stepSprite:setScale(0.8)
		self.bookBgSprite:addChild(stepSprite)

		-- 显示阶位锚点
		local pointSprite = ui.newSprite((v.isActive == true) and "wgcw_05.png" or "wgcw_06.png")
		pointSprite:setPosition(stepPos)
		pointSprite:setScale(0.8)
		self.bookBgSprite:addChild(pointSprite, 1)

		-- 显示连线
		if (lastNodePos ~= nil) then
			self.bookBgSprite:drawOneLine(lastNodePos, stepPos, (v.isActive == true))
		end
		
		-- 保存当前阶位信息
		lastNodePos = clone(stepPos)
	end

	-- 判断是否进阶到最高
	local function addLabel(strText, fontSize, fontColor, anchor, pos)
		local label = ui.newLabel({
			text = strText,
			size = fontSize,
			color = fontColor or cc.c3b(0x46, 0x22, 0x0d),
			anchorPoint = anchor,
		})
		label:setPosition(pos)
		self.infoBgSprite:addChild(label)
	end
	if (nextConfig == nil) then
		addLabel(TR("该内功心法已进阶到最高"), 35, Enums.Color.eRed, cc.p(0.5, 0.5), cc.p(320, 220))
		return
	end

	-- 提示文字
	addLabel(TR("内功进阶后可增加基础属性和洗炼上限"), 20, Enums.Color.eBrown, cc.p(0.5, 0.5), cc.p(300, 330))
	addLabel(TR("基础洗炼上限+%d%%", (nextConfig.stepAttrRAdd-10000)/100), 18, Enums.Color.eDarkGreen, cc.p(1, 0.5), cc.p(630, 329))

	-- 基础属性变化
	local attrPosList = {cc.p(170, 295), cc.p(470, 295), cc.p(170, 255), cc.p(470, 255)}
	local attrList = Utility.analysisStrAttrList(zhenjueModel.initAttrStr)
	for i,v in ipairs(attrList) do
		-- 显示背景
		local tempSprite = ui.newScale9Sprite("c_39.png", cc.size(240, 33))
		tempSprite:setPosition(attrPosList[i])
		self.infoBgSprite:addChild(tempSprite)

		-- 属性值
		local oldValue = math.floor(v.value * currConfig.stepAttrRAdd / 10000)
		local newValue = math.floor(v.value * nextConfig.stepAttrRAdd / 10000)
		local baseAttrStr = Utility.getAttrViewStr(v.fightattr, oldValue, false)
		local tempLabel = ui.newLabel({
			text = string.format("%s:%s %s(+%s)", FightattrName[v.fightattr], baseAttrStr, Enums.Color.eDarkGreenH, newValue - oldValue),
			color = cc.c3b(0x46, 0x22, 0x0d),
		})
		tempLabel:setAnchorPoint(cc.p(0, 0.5))
		tempLabel:setPosition(10, 16)
		tempSprite:addChild(tempLabel)
	end

	-- 显示需求材料
	local resList = Utility.analysisStrResList(nextConfig.consume)
	for _,v in ipairs(resList) do
		local holdNum = Utility.getOwnedGoodsCount(v.resourceTypeSub, v.modelId)
		if Utility.isZhenjue(v.resourceTypeSub) then
			holdNum = ZhenjueObj:getCountByModelId(v.modelId, self.mFilter)
		end
		v.ownNum = holdNum
	end
	self.infoBgSprite:showConsumeRes(resList)

	-- 显示进阶按钮
	self.btnStepUp = ui.newButton({
        normalImage = "ng_21.png",
        position = cc.p(510, 160),
        clickAction = function()
        	self:requestStepUp(resList)
        end
    })
    self.infoBgSprite:addChild(self.btnStepUp)
end

-- 请求进阶
function ZhenjueStepUpLayer:requestStepUp(resList)
	-- 判断材料是否足够
	local idList = {}
	for _,v in ipairs(resList) do
		if (v.ownNum < v.num) then
			Utility.showResLackLayer(v.resourceTypeSub, v.modelId)
			return
		end
		-- 获取需要用到的内功ID
		if Utility.isZhenjue(v.resourceTypeSub) then
			for idx,tmpItem in ipairs(ZhenjueObj:findByModelId(v.modelId, self.mFilter)) do
				if (idx <= v.num) then
					table.insert(idList, tmpItem.Id)
				end
			end
		end
	end

	-- 发送请求
    HttpClient:request({
        moduleName = "Zhenjue",
        methodName = "ZhenjueStepUp",
        svrMethodData = {self.mZhenjueId, idList},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return 
            end
           
            -- 修正缓存数据
            ZhenjueObj:modifyZhenjueItem(response.Value.ZhenjueInfo)

            -- 删除使用的材料
            for _, id in ipairs(idList) do
            	ZhenjueObj:deleteZhenjueById(id)
		    end

		    -- 刷新父页面
		    if (self.mRefreshFunc ~= nil) then
		    	self.mRefreshFunc()
		    end

		    -- 播放音效
		    MqAudio.playEffect("zhaomu.mp3")

		    -- 播放特效
		    self.btnStepUp:setEnabled(false)
		    ui.newEffect({
                parent = self.mParentLayer,
                effectName = "effect_ui_waigongfanye",
                position = cc.p(320, 585),
                loop = false,
                endRelease = true,
                endListener = function ()
                    -- 刷新界面
            		self:refreshUI()
                end
            })
        end
    })
end

return ZhenjueStepUpLayer