--[[
	文件名：DlgPetNirvanaLayer.lua
	描述：外功参悟碎片不足时，弹出散功对话框
	创建人: peiyaoqiang
	创建时间: 2017.08.21
--]]

local DlgPetNirvanaLayer = class("DlgPetNirvanaLayer", function()
	return display.newLayer()
end)

-- 构造函数
function DlgPetNirvanaLayer:ctor(params)
    -- 读取参数
    self.mPetId = params.petId
    self.mDebrisModelId = params.debrisModelId
    self.mCallback = params.callback
    
	-- 添加弹出框层
	local bgLayer = require("commonLayer.PopBgLayer").new({
		title = TR("获得碎片"),
		bgSize = cc.size(580, 400),
		closeImg = "c_29.png",
		closeAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self:addChild(bgLayer)

	-- 保存弹窗控件信息
	self.mBgSprite = bgLayer.mBgSprite
	self.mBgSize = bgLayer.mBgSprite:getContentSize()

	-- 初始化UI
	self:initUI()
end

-- 初始化UI
function DlgPetNirvanaLayer:initUI()
    -- 显示底框 
    local tmpGraySprite = ui.newScale9Sprite("c_17.png", cc.size(self.mBgSize.width - 60, self.mBgSize.height - 170))
    tmpGraySprite:setAnchorPoint(0.5, 1)
    tmpGraySprite:setPosition(self.mBgSize.width * 0.5, 325)
    self.mBgSprite:addChild(tmpGraySprite)

    -- 提示文字1
    local info1Label = ui.newLabel({
        text = TR("您有一个未上阵且未培养过的外功秘籍"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 22,
        anchorPoint = cc.p(0.5, 0.5),
        x = self.mBgSize.width * 0.5,
        y = 300,
    })
    self.mBgSprite:addChild(info1Label)

    -- 显示外功头像
    local petInfo = PetObj:getPet(self.mPetId)
    local tempCard = CardNode:create({
        cardShape = Enums.CardShape.eSquare,
        allowClick = true,
    })
    tempCard:setPosition(self.mBgSize.width * 0.5, 220)
    tempCard:setPet(petInfo, {CardShowAttr.eBorder, CardShowAttr.eName})
    self.mBgSprite:addChild(tempCard)

    -- 提示文字2
    local petBase = PetModel.items[petInfo.ModelId]
    local goodBase = GoodsModel.items[self.mDebrisModelId]
    local outNum = goodBase.maxNum
    if (petBase.rebornOutput ~= nil) then
        local tmpOutList = string.split(petBase.rebornOutput, ",")
        outNum = tonumber(tmpOutList[3])
    end
    local info2Label = ui.newLabel({
        text = TR("将其散功后可得到%s%d%s个%s%s", Enums.Color.eNormalGreenH, outNum, "#46220D", Enums.Color.eNormalGreenH, goodBase.name),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 22,
        anchorPoint = cc.p(0.5, 0.5),
        x = self.mBgSize.width * 0.5,
        y = 120,
    })
    self.mBgSprite:addChild(info2Label)

	-- 确定按钮
	local comfirmBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("散功"),
		clickAction = function ()
			self:requestNirvana()
		end
	})
	comfirmBtn:setAnchorPoint(cc.p(0.5, 0))
	comfirmBtn:setPosition(self.mBgSize.width * 0.5, 30)
	self.mBgSprite:addChild(comfirmBtn)
end

-- 初始化阵容数据
function DlgPetNirvanaLayer:requestNirvana()
	HttpClient:request({
        moduleName = "Pet",
        methodName = "PetRebirth",
        svrMethodData = {self.mPetId},
        callback = function(data)
            if (not data) or (not data.Value) or (data.Status ~= 0) then
                return
            end

            PetObj:deletePetById(self.mPetId)
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
            if self.mCallback then
                self.mCallback()
            end
            LayerManager.removeLayer(self)
        end})
end

return DlgPetNirvanaLayer
