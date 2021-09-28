-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_prayActivity = i3k_class("wnd_prayActivity", ui.wnd_base)
function wnd_prayActivity:ctor()
    self.prayData = nil
    self.selectDropId = 0
    self.selectImage = nil
    self.npc = {}
    self.items = {}
end

function wnd_prayActivity:configure()
    self.dialogue = self._layout.vars.dialogue
    self.npcName = self._layout.vars.npcName
    self.npcmodule = self._layout.vars.npcmodule
    self.ok_btn = self._layout.vars.ok_btn
    self.close_btn = self._layout.vars.close_btn
    self:initSelectedBox( self._layout.vars )
end

function wnd_prayActivity:initSelectedBox( widgets )
    for i=1,4 do
        local bg = "item" .. i .. "bg"
        local image = "item" .. i .. "Image"
        local btn = "item" .. i .. "btn"
        local selectImage = "selectImage" .. i
        local text = "selectName" .. i
        self.items[i] = {bg = widgets[bg],
                        image = widgets[image],
                        btn = widgets[btn],
                        selectImage = widgets[selectImage],
                        text = widgets[text]
                    }
    end
end

function wnd_prayActivity:refresh(data)
    self.prayData = data.prayData
    self.dialogue:setText(self.prayData.desc)
    for k,v in ipairs(self.items) do
        local prayActivityReward = i3k_db_pray_activity_rewards[self.prayData.prayDropIDs[k]]
        if prayActivityReward == nil then
            v.bg:hide()
            v.image:hide()
            v.btn:setVisible(false)
            v.selectImage:hide()
        else
            v.selectImage:hide()
            v.text:setText(prayActivityReward.name)
            v.image:setImage(g_i3k_db.i3k_db_get_icon_path(prayActivityReward.image))
            v.btn:onClick(self, self.itembtn, {selectDropId = self.prayData.prayDropIDs[k], selectImage = v.selectImage })
        end
    end
    self.selectDropId = self.prayData.prayDropIDs[1]
    self.selectImage = self.items[1].selectImage
    self.selectImage:show()
    self.ok_btn:onClick(self, self.okbtn)
    self.close_btn:onClick(self, self.cancel)
    ui_set_hero_model(self.npcmodule, data.npcModule)
    self.npcName:setText(data.npcName)
    self.npc.name = data.npcName
    self.npc.module = data.npcModule
end

function wnd_prayActivity:okbtn(sender)
    g_i3k_ui_mgr:OpenUI(eUIID_PrayActivityTurntable)
    g_i3k_ui_mgr:RefreshUI(eUIID_PrayActivityTurntable, {prayData = self.prayData, selectDropId = self.selectDropId, npcName = self.npc.name, npcModule = self.npc.module})
    self:onCloseUI()
end

function wnd_prayActivity:cancel(sender)
    self:onCloseUI()
end

function wnd_prayActivity:itembtn(sender, data)
    self.selectImage:hide()
    self.selectDropId = data.selectDropId
    self.selectImage = data.selectImage
    self.selectImage:show()
end

function wnd_create(layout, ...)
    local wnd = wnd_prayActivity.new()
    wnd:create(layout, ...)
    return wnd
end