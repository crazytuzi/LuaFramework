--[[
 --
 -- add by vicky
 -- 2014.09.01
 --
 --]]

require("data.data_error_error") 

local LackBagSpaceLayer = class("LackBagSpaceLayer", function() 
	return display.newNode()
end)


-- 整理背包，跳转到背包界面
function LackBagSpaceLayer:resetBag()

    if self._cleanup then
        self._cleanup()
        return
    end

    local firstBag = self._bagObj[1]
    if firstBag == nil then 
        GameStateManager:ChangeState(GAME_STATE.STATE_BEIBAO)
        return 
    end 

    if firstBag.type == BAG_TYPE.zhuangbei then 
        -- 装备
        GameStateManager:ChangeState(GAME_STATE.STATE_EQUIPMENT, 1)

    elseif firstBag.type == BAG_TYPE.shizhuang then 
        -- 时装 (暂时没有，临时的)
        GameStateManager:ChangeState(GAME_STATE.STATE_BEIBAO)

    elseif firstBag.type == BAG_TYPE.zhuangbei_suipian then 
        -- 装备碎片
        GameStateManager:ChangeState(GAME_STATE.STATE_EQUIPMENT, 2)

    elseif firstBag.type == BAG_TYPE.wuxue then 
        -- 武学
        GameStateManager:ChangeState(GAME_STATE.STATE_BEIBAO, 2)

    elseif firstBag.type == BAG_TYPE.canhun then 
        -- 残魂
        GameStateManager:ChangeState(GAME_STATE.STATE_XIAKE, 2)

    elseif firstBag.type == BAG_TYPE.zhenqi then 
        -- 真气
        GameStateManager:ChangeState(GAME_STATE.STATE_JINGYUAN, 2)

    elseif firstBag.type == BAG_TYPE.daoju then 
        -- 道具
        GameStateManager:ChangeState(GAME_STATE.STATE_BEIBAO, 1)

    elseif firstBag.type == BAG_TYPE.xiake then 
        -- 侠客
        GameStateManager:ChangeState(GAME_STATE.STATE_XIAKE, 1)

    end 

end


-- 扩展背包
function LackBagSpaceLayer:extendBag()
    local function extend(bag)
        RequestHelper.extendBag({
            callback = function(data)
                dump(data)
                if string.len(data["0"])  > 0 then
                    CCMessageBox(data["0"], "Error")
                else
                    if self._callback ~= nil then
                        self._callback(data) 
                    end

                    self:removeFromParentAndCleanup(true)
                    local curGold = data["3"]
                    game.player:setGold(curGold) 
                    PostNotice(NoticeKey.CommonUpdate_Label_Gold) 

                    local str = "恭喜您已开启" .. tostring(bag.size) .. "个" .. ResMgr.getBagTypeDes(bag.type) .. "背包位置" 
                    show_tip_label(str) 
                end 
            end,
            type = bag.type
        })
    end

    local firstBag = self._bagObj[1]

    if firstBag.cost < 0 then
        show_tip_label(ResMgr.getBagTypeDes(firstBag.type) .. "背包已经达到最大扩展空间, 请整理背包")
    else
        -- local layer = require("utility.MsgBox").new({
        --         size = CCSizeMake(500, 210),
        --         leftBtnName = "取消",
        --         rightBtnName = "确定",
        --         content = string.format("是否花费 [%d] 元宝开启 [%d] 个位置", firstBag.cost, firstBag.size),
        --         leftBtnFunc = function()
        --         	self:removeFromParentAndCleanup(true)
        --         end,
        --         rightBtnFunc = function()
        --             if game.player:getGold() < firstBag.cost then 
        --                 show_tip_label("元宝不足")
        --             else
        --                 extend(firstBag)
        --             end 
        --         end
        --     })
        local layer = require("utility.CostTipMsgBox").new({
                tip = string.format("开启%d个位置吗？", firstBag.size),
                listener = function()
                    if(game.player.m_gold >= firstBag.cost) then
                        extend(firstBag)
                    else 
                        show_tip_label(data_error_error[400004].prompt) 
                    end
                end,
                cost = firstBag.cost,
            })
            self:addChild(layer)
    end
end


function LackBagSpaceLayer:ctor(param)
	self._bagObj = param.bagObj
    self._callback = param.callback
    self._cleanup = param.cleanup

	if type(self._bagObj) ~= "table" or #self._bagObj <= 0 then
        CCMessageBox("the  data of package from server is Error", "Tip")
        self:removeFromParentAndCleanup(true)
        return
    end

    local contentStr = ""
    for i, v in ipairs(self._bagObj) do 
        contentStr = contentStr .. ResMgr.getBagTypeDes(v.type) 
        if i < #self._bagObj then
            contentStr = contentStr .. "、"
        else
            contentStr = contentStr .. "背包空间不足，请整理或扩充空间"
        end
    end

    local msgBox = require("utility.MsgBox").new({
        size = CCSizeMake(500, 300),
        content = contentStr,
        leftBtnName = "整理背包",
        rightBtnName = "扩充空间",
        showClose = true, 
        leftBtnFunc = handler(self, LackBagSpaceLayer.resetBag),
        rightBtnFunc = handler(self, LackBagSpaceLayer.extendBag),
        directclose = true
    })
    self:addChild(msgBox)
end



return LackBagSpaceLayer