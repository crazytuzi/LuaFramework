local MoShenDescriptionDialog = class("MoShenDescriptionDialog",UFCCSModelLayer)

--注意添加json文件
function MoShenDescriptionDialog.create()
	local layer = MoShenDescriptionDialog.new("ui_layout/moshen_MoShenHelp.json",Colors.modelColor)
	return layer
end


function MoShenDescriptionDialog:ctor(...)
	self.super.ctor(self,...)
    self:_setWidgets()
    self:showAtCenter(true)
    self:registerTouchEvent(false,true,0)
    self:playAnimation("Animation_goon",function() 
    end)
    self:getLabelByName("Label_panjunTitle"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_gongxunTitle"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_jiangzhengTitle"):createStroke(Colors.strokeBrown,1)
end


function MoShenDescriptionDialog:_setWidgets()
    local Label_rebelcontent = self:getLabelByName("Label_panjun")
    --Label_rebelcontent:setText("1.攻打叛军会获得功勋,每日功勋累计到一定值可以领取大量游戏资源.\n2.每日会根据功勋排行与伤害排行发放奖章,奖章可以在奖章商店中购买珍贵资源与绝版武将")
    Label_rebelcontent:setText(G_lang:get("LANG_MOSHEN_DESCRIPTION_REBEL_CONTENT"))
    local Label_featscontent = self:getLabelByName("Label_gongxun")
    --Label_featscontent:setText("1.我们每天攻打主线副本与剧情副本时.有一定几率发现叛军，我们可以自己攻打叛军,也可以邀请好友与我们一起攻打叛军.\n2.每次攻打叛军会获得功勋值,造成的伤害越高，功勋值越多，武将的星级会提升对叛军的攻击倍数.\n3.当叛军被击杀时，发现叛军的玩家和最后击杀叛军的玩家会获得额外奖励.")
    Label_featscontent:setText(G_lang:get("LANG_MOSHEN_DESCRIPTION_FEATS_CONTENT"))
    local Label_medalcontent = self:getLabelByName("Label_jiangzhang")
    --Label_medalcontent:setText("1.奖章是十分珍贵的资源,只在叛军活动每天的排行榜发放.\n2.排行榜分两种,一种是每日功勋排行榜,一种是每日伤害排行榜,两种排行榜都只发放给前200名玩家奖章\n3.奖章可以在奖章商店中兑换珍贵的绝版武将以及绝版装备")
    Label_medalcontent:setText(G_lang:get("LANG_MOSHEN_DESCRIPTION_MEDAL_CONTENT"))
    self:getLabelByName("Label_jiangzhengTitle"):setText(G_lang:get("LANG_GOODS_JIANG_ZHANG"))
end

function MoShenDescriptionDialog:onLayerEnter()
    require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_bg"), "smoving_bounce")
    self:closeAtReturn(true)
end

function MoShenDescriptionDialog:onTouchEnd( xpos, ypos )
    self:animationToClose()
end

return MoShenDescriptionDialog
	
