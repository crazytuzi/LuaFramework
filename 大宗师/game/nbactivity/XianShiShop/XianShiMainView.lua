--
-- Author: Daneil
-- Date: 2015-03-14 15:56:17
--
 local MAX_ZORDER = 1111 
 require("game.Biwu.BiwuFuc")
 local data_item_item = require("data.data_item_item")
 local data_xianshishangdian_xianshishangdian = require("data.data_xianshishangdian_xianshishangdian")
 local XianShiMainView = class("XianShiMainView", function()
 		return display.newNode()
 end)


 function XianShiMainView:ctor(param)
    self._curInfoIndex = -1 
    
 	local viewSize = param.viewSize 
 	local proxy = CCBProxy:create()
 	self._rootnode = {} 
 	
    local node = CCBuilderReaderLoad("nbhuodong/xianshishangdian_layer.ccbi", proxy, self._rootnode, self, viewSize)
    self:addChild(node) 

    local titleSize = self._rootnode["titlebng"]:getContentSize()

    self._rootnode["listbng"]:setContentSize(cc.size(display.width * 0.98 , param.viewSize.height - titleSize.height - 20))
    self._rootnode["listview"]:setContentSize(cc.size(display.width * 0.95 , param.viewSize.height- titleSize.height - 50))


    

    local timetitleLabel = ui.newTTFLabelWithOutline({  text = "活动有效期:", 
                                            size = 20, 
                                            color = ccc3(255,255,255),
                                            outlineColor = ccc3(0,0,0),
                                            align= ui.TEXT_ALIGN_CENTE,
                                            font = FONTS_NAME.font_fzcy 
                                            })
    local timeLabel      = ui.newTTFLabelWithOutline({  text = "201012125455154541545154545415", 
                                            size = 20, 
                                            color = ccc3(30,255,0),
                                            outlineColor = ccc3(0,0,0),
                                            align= ui.TEXT_ALIGN_CENTE,
                                            font = FONTS_NAME.font_fzcy 
                                            })
    self._rootnode["timetitle"]:setString("")
    self._rootnode["timelabel"]:setString("")
    self._rootnode["timetitle"]:removeAllChildren()
    self._rootnode["timelabel"]:removeAllChildren()
    self._rootnode["timetitle"]:addChild(timetitleLabel)
    self._rootnode["timelabel"]:addChild(timeLabel)
    timeLabel:setPositionX(10)

    self:getData(function() 
        self:setUpView()
    end
    )

end

function XianShiMainView:setUpView()

    self._data = self._itemList
    
    local boardWidth = self._rootnode["listview"]:getContentSize().width 
    local boardHeight = self._rootnode["listview"]:getContentSize().height
    local showBuyBox
    showBuyBox = function(index,cell)
        local itemData = { 
            name = "",
            iconType = ResMgr.getResType(data_item_item[self._data[index + 1].itemid].type),
            id = self._data[index + 1].itemid,
            had  = self._data[index + 1].hasNum,         --剩余次数
            limitNum = self._data[index + 1].canBuyNum,  --每次输入的最大次数
            needReputation = 10, --价格
        }
        if self._data[index + 1].num1 == 0 then
            show_tip_label("购买次数为0")
            return
        end
        local popup = require("game.Biwu.ExchangeCountBox").new({
                reputation = game.player:getGold(), --玩家元宝
                itemData = itemData, 
                listener = function(num)
                    self:confirmFunc(index,num,showBuyBox,cell)
                end, 
                closeFunc = function()
                    --cell:updateExchangeBtn(true) 
                end
            })
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        popup:setPositionY(0)
        display.getRunningScene():addChild(popup,1000000) 
    end

    -- 创建 
    local function createFunc(index)
        local item = require("game.nbactivity.XianShiShop.XianShiItemView").new()
        return item:create({
            index = index, 
            viewSize = CCSizeMake(boardWidth, boardHeight), 
            itemData = self._data[index + 1],
            confirmFunc = showBuyBox
            })
    end
    -- 刷新 
    local function refreshFunc(cell, index)
        cell:refresh({
            index = index, 
            itemData = self._data[index + 1],
            confirmFunc = showBuyBox
            })
    end
    local cellContentSize = require("game.nbactivity.XianShiShop.XianShiItemView").new():getContentSize()
    self.ListTable = require("utility.TableViewExt").new({
        size        = CCSizeMake(boardWidth, boardHeight), 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum     = #self._data, 
        cellSize    = cellContentSize, 
        direction   = kCCScrollViewDirectionVertical
        })
    self.ListTable:setPosition(0, 0)
    self._rootnode["listview"]:addChild(self.ListTable)
    self._rootnode["listview"]:setPositionY(self._rootnode["listview"]:getPositionY() + 5)
end

function XianShiMainView:getData(func)
    local init = function(data)
        self._itemList = data.toolsList
        self._vipLevel = data.vipLevel

        for k,v in pairs(self._itemList) do
            v.itemid = data_xianshishangdian_xianshishangdian[v.id].itemid
            v.itemnum = data_xianshishangdian_xianshishangdian[v.id].num
            v.vip = data_xianshishangdian_xianshishangdian[v.id].vip
            v.price = data_xianshishangdian_xianshishangdian[v.id].price
        end

        dump(self._itemList)
        func()
    end
    RequestHelper.xianshiShopSystem.getBaseInfo({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        init(data.rtnObj)
                    end
                end
                })

end

function XianShiMainView:confirmFunc(index,num,showBuyBox,cell)
    self._data[index + 1].canBuyNum = self._data[index + 1].canBuyNum - num
    --刷新
    if self._data[index + 1].canBuyNum > 0 then
        local param = {
            index = index, 
            itemData = self._data[index + 1],
            confirmFunc = showBuyBox
        }
        self.ListTable:reloadCell(index,param)
    else
        table.remove(self._data,index + 1)
        self.ListTable:resetListByNumChange(#self._data)
    end

    --[[-- 弹出购买的物品确认框
    local cellDatas = {}
    local itemData = { 
        id = self._data[index + 1].item, 
        iconType = self._data[index + 1].iconType, 
        num = self._data[index + 1].num,
        name =  self._data[index + 1].name,
        describe = self._data[index + 1].dis
    }
    table.insert(cellDatas, itemData)
    self:addChild(require("game.Huodong.rewardInfo.RewardInfoMsgBox").new({
            cellDatas = cellDatas, 
            num = num
        }), 10)

    --刷新荣誉值
    self.nameDis:setString(data.honor)--]]
end
 
return XianShiMainView 

