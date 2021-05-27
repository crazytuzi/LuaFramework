Horoscope = Horoscope or BaseClass(BaseView)

function Horoscope:__init()
    self.title_img_path = ResPath.GetWord("xinghun_name")
    self.is_modal =true
    self.texture_path_list = {
        'res/xui/horoscope.png',
        'res/xui/role.png',
    }
	self.config_tab = {
		  {"common_ui_cfg", 1, {0}},
      {"common_ui_cfg", 2, {0}, nil, 999},
 
	}
    -- self.need_del_objs = {}
    -- self.fight_power_view = nil
    -- self.cell_list = {}
    -- self.effect_show1 = nil
    --self:GetConstellationDataList(function(data)
    --    HoroscopeData.Instance:GetConstellationData(data.equip_slot)
    --end)
   require("scripts/game/role/horoscope/horoscope_view").New(ViewDef.Horoscope.HoroscopeView)
   require("scripts/game/role/horoscope/slot_strengthen_view").New(ViewDef.Horoscope.SlotStrengthen)
   require("scripts/game/role/horoscope/collection_view").New(ViewDef.Horoscope.Collection)
end

function Horoscope:__delete()
    self.cell_list = {}
end

function Horoscope:LoadCallBack()
    
end

function Horoscope:ReleaseCallBack()
	
end

function Horoscope:ShowIndexCallBack()
	self:Flush()
end


function Horoscope:OnFlush()
   
end

return Horoscope