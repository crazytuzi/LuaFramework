local MoShenAppearDialog = class("MoShenAppearDialog",UFCCSModelLayer)
require("app.cfg.rebel_info")

local PlotlineDungeonType = require("app.const.PlotlineDungeonType")

function MoShenAppearDialog.show(rebelId,rebelLevel,func,...)
	if not rebelId or type(rebelId) ~= "number" or rebelId == 0 then
		return
	end
	local rebel = rebel_info.get(rebelId)
	if not rebel then
		return 
	end
	local layer =  MoShenAppearDialog.new("ui_layout/moshen_MoShenAppearDialog.json",Colors.modelColor,rebel,rebelLevel,func,...)
	uf_sceneManager:getCurScene():addChild(layer)
end

function MoShenAppearDialog:ctor(json,color,rebel,rebelLevel,func,...)
	self._callback = func
	self._rebel = rebel
	self._rebelLevel = rebelLevel
	self.super.ctor(self,...)
	self:showAtCenter(true)
	local knightPanel = self:getPanelByName("Panel_knight")
	local boss = require("app.scenes.common.KnightPic").createKnightPic(self._rebel.res_id,knightPanel,nil,true)
	knightPanel:setScale(0.7)



	self:registerBtnClickEvent("Button_ok",function()
		if self._callback ~= nil then
			self._callback(true)
		end
		
		local sceneName = "app.scenes.dungeon.DungeonMainScene"
		local dungeonType = G_Me.userData:getPlotlineDungeonType()

    	if dungeonType == PlotlineDungeonType.HARD then
    		sceneName = "app.scenes.harddungeon.HardDungeonMainScene"
    	end

		uf_sceneManager:replaceScene(require("app.scenes.moshen.MoShenScene").new(nil,nil,nil,nil,
			GlobalFunc.sceneToPack(sceneName,{})))
		end)

	self:registerBtnClickEvent("Button_No",function()
		if self._callback ~= nil then
			self._callback(false)
		end
		self:animationToClose()
		end)
	self:registerBtnClickEvent("Button_close",function()
		if self._callback ~= nil then
			self._callback(false)
		end
		self:animationToClose()
		end)
end

function MoShenAppearDialog:onLayerEnter()
	self:closeAtReturn(true)
	--提示文字
	local label = self:getLabelByName("Label_content")
	label:setVisible(false)
	local size = label:getContentSize()
	self._richText = CCSRichText:create(size.width+50, size.height+30)
	self._richText:setFontSize(label:getFontSize())
	self._richText:setFontName(label:getFontName())

	local _color=Colors.qualityDecColors[self._rebel.quality]
	local text = G_lang:get("LANG_DUNGEON_MOSHEN",{rebel_name=self._rebel.name,level=self._rebelLevel,color=_color})
	self._richText:appendXmlContent(text)
	self._richText:reloadData()
	local x,y = label:getPosition()
	self._richText:setPosition(ccp(x+10,y))
	self:getImageViewByName("ImageView_back"):addChild(self._richText)
end

return MoShenAppearDialog