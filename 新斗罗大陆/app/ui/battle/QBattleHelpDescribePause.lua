local QUIWidget = import(".QUIWidget")
local QBattleHelpDescribePause = class("QBattleHelpDescribePause", function()
    return display.newNode()
end)
local QRichText = import("...utils.QRichText")
local QStaticDatabase = import("...controllers.QStaticDatabase")

--初始化
function QBattleHelpDescribePause:ctor(options)
	local ccbFile = "Dialog_Base_Help.ccbi"
	local owner = {}
	owner.onTriggerClose = handler(self, self.onClose)
	local proxy = CCBProxy:create()
	self._ccbNode = CCBuilderReaderLoad(ccbFile, proxy, owner)
	self._ccbOwner = owner
	owner.node_rule:setVisible(false)
	self:addChild(self._ccbNode)

	owner.frame_tf_title:setString("帮助")

	local content = [[1.勾选##x魂师自动走位##d后，己方魂师释放范围攻击技能前，会先自动走到能够命中目标的位置。\n2.取消勾选后，若魂师释放自动范围攻击技能时无法命中任何敌人，则会在有敌人进入攻击范围后才释放该技能。\n3.此功能在PVP中始终开启。]]

	local richTextFontOptions = {}
	richTextFontOptions.defaultColor = ccc3(134,85,55)
	richTextFontOptions.defaultSize = 20
	richTextFontOptions.stringType = 1
	richTextFontOptions.lineSpacing = 0

	local text = QRichText.new(content, 720, richTextFontOptions)
	text:setAnchorPoint(ccp(0,1))
	text:setPosition(ccp(30, -10))
	owner.sheet:addChild(text)
end

function QBattleHelpDescribePause:onClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then
        return
    end
	self:removeFromParentAndCleanup(true)
end

return QBattleHelpDescribePause

