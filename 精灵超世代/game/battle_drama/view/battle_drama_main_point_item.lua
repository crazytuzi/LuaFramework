-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      剧情副本关卡点item
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattleDramaMainPointItem = class("BattleDramaMainPointItem",function ()
    return  ccui.Widget:create()
end)

BattleDramaMainPointItem.WIDTH = 50
BattleDramaMainPointItem.HEIGHT = 50

function BattleDramaMainPointItem:ctor()
    self.ctrl = BattleDramaController:getInstance()
    self.model = self.ctrl:getModel()
    self.is_big_point = FALSE --是否为大关
    self:initUi()
end

--初始化UI
function BattleDramaMainPointItem:initUi()
    self.size = cc.size(BattleDramaMainPointItem.WIDTH,BattleDramaMainPointItem.HEIGHT)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)
    self:setCascadeOpacityEnabled(true)
    self:retain()
    self.normal_img = createSprite(PathTool.getResFrame("battle","battle_normal_point"),self.size.width/2,self.size.height/2,self,cc.p(0.5,0.5))

    self:setVisible(false)
    self:registerEvent()
end

function BattleDramaMainPointItem:registerEvent()
    self:addTouchEventListener(function(sender, eventType)
        if self.is_big_point == TRUE then
            customClickAction(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.data then
                    self.ctrl:openDramBossInfoView(true,self.data)
                end
            end
        end
    end)
end

--设置数据
function BattleDramaMainPointItem:setData(data)
    if not data then
        return 
    end
    self.data = data
    --self.swap_boss_max_data = swap_boss_max_data
    local drama_data = self.model:getDramaData()
    self.is_big_point = data.info_data.is_big
    self.dun_id = data.info_data.id
    self.chapter_id = data.info_data.chapter_id
    self.next_id = data.info_data.next_id
    self.v_data = data.v_data
    self:updateStatus(self.v_data.status, self.is_big_point)  
end
function BattleDramaMainPointItem:updateStatus(status,is_big_point)
        self:setVisible(false)
        if status == 1 or status == 2 or status == 3 then --制作中,有倒计时
            self:setVisible(true)
            if status == 3 and is_big_point == TRUE then
                self:setTouchEnabled(true)
                loadSpriteTexture(self.normal_img, PathTool.getResFrame("battle", "battle_drama_has_ack"))
                -- if swap_boss_max_data.dun_id == self.dun_id then
                --     if self.swap_sp and not tolua.isnull(self.swap_sp) then
                --         self.swap_sp:setVisible(true)
                --     end
                -- end
            else
                if is_big_point == TRUE then 
                    self:setTouchEnabled(true)
                    loadSpriteTexture(self.normal_img, PathTool.getResFrame("battle", "battle_drama_no_ack"))
                end
            end
        else
            if is_big_point == TRUE then
                -- self:setVisible(true)
                -- self:setTouchEnabled(true)
                loadSpriteTexture(self.normal_img, PathTool.getResFrame("battle", "battle_drama_no_ack"))
            end
        end
end


--清除数据
function BattleDramaMainPointItem:clearInfo()
    doStopAllActions(self)
    self:removeFromParent()
end

--删掉的时候关闭
function BattleDramaMainPointItem:DeleteMe()
    doStopAllActions(self)
    self:removeAllChildren()
    self:removeFromParent()
    self:release()
end