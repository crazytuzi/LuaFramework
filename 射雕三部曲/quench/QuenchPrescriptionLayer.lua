--[[
	文件名：QuenchPrescriptionLayer.lua
	描述：丹方界面
	创建人：yanghongsheng
	创建时间： 2017.12.21
--]]

local QuenchPrescriptionLayer = class("QuenchPrescriptionLayer", function(params)
	return display.newLayer()
end)

--[[
	params:
		prescriptionList	丹方列表
		callback			回调
]]

function QuenchPrescriptionLayer:ctor(params)
	params = params or {}
	-- 丹方列表
	self.mPrescriptionList = params.prescriptionList or {}
	-- 丹方具体数据
	self.mPrescriptionInfoList = {}
	--回调
	self.callback = params.callback
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(586, 730),
        title = TR("丹方"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 初始化数据
    self:refreshData()
	-- 创建页面控件
	self:initUI()
end

function QuenchPrescriptionLayer:refreshData()
	-- 初始化丹方数据
	if not next(self.mPrescriptionInfoList) then
		for _, prescriptionId in ipairs(self.mPrescriptionList) do
			-- 丹方数据
			local prescriptionData = {
				id = prescriptionId,		-- 丹方Id
				name = "",					-- 丹名
				danInfo = {},				-- 成丹信息
				materialList = {},			-- 丹材列表
			}
			-- 获取丹名
			local medicineFormula = MedicinePrescriptionRelation.items[prescriptionId]
			local medicineInfo = Utility.analysisStrResList(medicineFormula.getGoods)[1]
			prescriptionData.name = Utility.getGoodsName(medicineInfo.resourceTypeSub, medicineInfo.modelId)
			prescriptionData.name = prescriptionData.name .. TR("丹方")

			-- 成丹信息
			prescriptionData.danInfo = medicineInfo

			-- 获取丹材
			local herbsList = string.splitBySep(medicineFormula.needGoodsA, ",")
			for _, herbs in pairs(herbsList) do
			    local herbsInfo = {
			        resourceTypeSub = ResourcetypeSub.eQuench,
			        modelId = tonumber(herbs),
			        num = Utility.getOwnedGoodsCount(ResourcetypeSub.eQuench, tonumber(herbs)),
			    }
			    table.insert(prescriptionData.materialList, herbsInfo)
			end

			-- 将丹方数据加入列表
			table.insert(self.mPrescriptionInfoList, prescriptionData)
		end
	-- 刷新药材数量
	else
		for _, prescriptionInfo in pairs(self.mPrescriptionInfoList) do
			for _, pelletInfo in pairs(prescriptionInfo.materialList) do
				pelletInfo.num = Utility.getOwnedGoodsCount(pelletInfo.resourceTypeSub, pelletInfo.modelId)
			end
		end
	end
end

function QuenchPrescriptionLayer:initUI()
	-- 列表背景
	local listBgSize = cc.size(534, 570)
	local listBgSprite = ui.newScale9Sprite("c_17.png", listBgSize)
	listBgSprite:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.52)
	self.mBgSprite:addChild(listBgSprite)
	-- 列表
	if next(self.mPrescriptionList) then
		local listView = ccui.ListView:create()
	    listView:setDirection(ccui.ScrollViewDir.vertical)
	    listView:setBounceEnabled(true)
	    listView:setContentSize(cc.size(listBgSize.width-20, listBgSize.height-20))
	    listView:setItemsMargin(5)
	    listView:setGravity(ccui.ListViewGravity.centerHorizontal)
	    listView:setAnchorPoint(cc.p(0.5, 0.5))
	    listView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
	    listBgSprite:addChild(listView)
	    self.pelletListView = listView

	    self:refreshList()
	else
		local emptyHint = ui.createEmptyHint(TR("还没激活丹方"))
		emptyHint:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.52)
		self.mBgSprite:addChild(emptyHint)
	end

    -- 确定按钮
	local closeBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("确定"),
			clickAction = function ()
				LayerManager.removeLayer(self)
			end
		})
	closeBtn:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.08)
	self.mBgSprite:addChild(closeBtn)
end

function QuenchPrescriptionLayer:createCell(index)
	local info = self.mPrescriptionInfoList[index]
	-- 项大小
    local cellSize = cc.size(self.pelletListView:getContentSize().width, 175)

    local layout = ccui.Layout:create()
    layout:setContentSize(cellSize)
    -- 背景
    local bgSprite = ui.newScale9Sprite("c_54.png", cellSize)
    bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
    layout:addChild(bgSprite)
    -- 题目
    local titleLabel = ui.newLabel({
            text = info.name,
            color = Enums.Color.eWhite,
            size = 24,
            outlineColor = Enums.Color.eBlack,
        })
    titleLabel:setAnchorPoint(cc.p(0.5, 0.5))
    titleLabel:setPosition(cellSize.width*0.5, cellSize.height-20)
    layout:addChild(titleLabel)
    -- 资源
    local cardList = ui.createCardList({
            maxViewWidth = cellSize.width*0.7,
            cardDataList = info.materialList,
            isSwallow = false,
        })
    cardList:setAnchorPoint(cc.p(0, 0.5))
    cardList:setPosition(cellSize.width*0.03, cellSize.height*0.4)
    layout:addChild(cardList)
    -- 炼制按钮
    local alchemyBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("炼制"),
            clickAction = function()
            	local info = self.mPrescriptionInfoList[index]
            	local minNum = 9999
                for _, res in pairs(info.materialList) do
                    if res.num <= 0 then
                        ui.showFlashView({text = TR("%s不足", GoodsModel.items[res.modelId].name)})
                        return
                    else
                    	minNum = minNum < res.num and minNum or res.num
                    end
                end

                self.alchemyBox = MsgBoxLayer.addAlchemyCount(info.name, info.danInfo, info.materialList, minNum, function (selCount)
                	self.scrollPos = self.pelletListView:getInnerContainerPosition()
                	self:requestPrescriptionAlchemy(info.id, selCount)
                	LayerManager.removeLayer(self.alchemyBox)
                end)
            end,
        })
    alchemyBtn:setPosition(cellSize.width*0.87, cellSize.height*0.45)
    alchemyBtn:setScale(0.9)
    layout:addChild(alchemyBtn)

    -- 项刷新
    layout.refresh = function ()
    	local info = self.mPrescriptionInfoList[index]
    	cardList.refreshList(info.materialList)
	end

	return layout
end

function QuenchPrescriptionLayer:refreshList()
	self.pelletListView:removeAllChildren()

	for i, prescriptionInfo in ipairs(self.mPrescriptionInfoList) do
		local item = self:createCell(i)
		self.pelletListView:pushBackCustomItem(item)
	end
end

--=========================服务器相关============================
-- 丹方炼丹
function QuenchPrescriptionLayer:requestPrescriptionAlchemy(prescriptionId, num)
    HttpClient:request({
        moduleName = "QuenchInfo",
        methodName = "AlchemyForPrescriptionId",
        svrMethodData = {prescriptionId, num},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- 显示获取奖励
            MsgBoxLayer.addGameDropLayer(response.Value.BaseGetGameResourceList, {}, TR("获得以下物品"), TR("炼丹成功"), {{text = TR("确定")}}, {})
            -- 更新数据
            self:refreshData()
            -- 更新列表
            self:refreshList()
            -- 滑动列表到当前项
            Utility.performWithDelay(self, function()
	            self.pelletListView:setInnerContainerPosition(self.scrollPos)
            end,0.01)
            -- 回调
            if self.callback then
            	self.callback(response)
            end
        end
    })
    
end

return QuenchPrescriptionLayer