local ContainerQuickEquip = {}
local var = {}
--local data = {GameConst.ITEM_WEAPON_POSITION,GameConst.ITEM_CLOTH_POSITION,GameConst.ITEM_HAT_POSITION,GameConst.ITEM_NICKLACE_POSITION,GameConst.ITEM_BELT_POSITION,
--GameConst.ITEM_BOOT_POSITION,GameConst.ITEM_GLOVE1_POSITION,GameConst.ITEM_GLOVE2_POSITION,GameConst.ITEM_RING1_POSITION,GameConst.ITEM_RING2_POSITION,
--GameConst.ITEM_MIRROR_ARMOUR_POSITION,GameConst.ITEM_DRAGON_BONE_POSITION,GameConst.ITEM_FACE_CLOTH_POSITION,GameConst.ITEM_CATILLA_POSITION}
local data = {GameConst.ITEM_WEAPON_POSITION,GameConst.ITEM_CLOTH_POSITION,GameConst.ITEM_HAT_POSITION,GameConst.ITEM_NICKLACE_POSITION,GameConst.ITEM_BELT_POSITION,
GameConst.ITEM_BOOT_POSITION,GameConst.ITEM_GLOVE1_POSITION,GameConst.ITEM_GLOVE2_POSITION,GameConst.ITEM_RING1_POSITION,GameConst.ITEM_RING2_POSITION,}
local name_data = {"武器","衣服","头盔","项链","腰带","鞋子","左手套","右手套","左戒指","右戒指","护心镜","龙骨","面巾","虎符",} 


function ContainerQuickEquip.initView(extend)
	var = {
		xmlPanel,
		
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerQuickEquip.uif")
	if var.xmlPanel then
		for i=1,#data do

			var.xmlPanel:getWidgetByName("Button_"..i):addClickEventListener(function( sender )
				if not GameSocket:getItemDefByPos(data[i]) then
					GameSocket:alertLocalMsg("该部位没有装备道具", "alert")
					return
				end
				local param = {
					name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "确认将"..name_data[i].."强化到"..extend.value.."级吗？", btnConfirm = "确认",btnCancel ="取消",
					confirmCallBack = function ()
						GameSocket:PushLuaTable("gui.ContainerSmelt.handlePanelData",GameUtilSenior.encode({actionid="quickQianghua",pos = data[i],nextlevel=extend.value,id=extend.id}))
					end
				}
				GameSocket:dispatchEvent(param)
			end)
		end
		return var.xmlPanel
	end
end

function ContainerQuickEquip.onPanelOpen(extend)
	
end

function ContainerQuickEquip.onPanelClose()

end

return ContainerQuickEquip