
LSRoleItem = class("LSRoleItem");


function LSRoleItem:New()
    self = { };
    setmetatable(self, { __index = LSRoleItem });
    return self;
end

function LSRoleItem:Init(gameObject)

    self.gameObject = gameObject;

    self.name = UIUtil.GetChildByName(self.gameObject, "UILabel", "name");
    self.level = UIUtil.GetChildByName(self.gameObject, "UILabel", "level");

    self.icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self.doIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "doIcon");

    self.doIcon.gameObject:SetActive(false);

end

function LSRoleItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end


function LSRoleItem:SetData(data)

    self.data = data;

    self.icon.spriteName = ConfigManager.GetCareerByKind(data.k).icon_id;
    self.name.text = data.n;
    self.level.text = data.l .. "";

    local s = data.p;

    if s == 1 then
        self.doIcon.spriteName = "agree";
        self.doIcon.gameObject:SetActive(true);
    else

        if data.accept == nil then
            self.doIcon.gameObject:SetActive(false);

        elseif data.accept == 1 then
            self.doIcon.spriteName = "agree";
            self.doIcon.gameObject:SetActive(true);

        elseif data.accept == 0 then
            self.doIcon.spriteName = "refuse";
            self.doIcon.gameObject:SetActive(true);

        end

    end

    self:SetActive(true);
end

function LSRoleItem:Dispose()

    self.gameObject = nil;

    self.name = nil;
    self.level = nil;

    self.icon = nil;
    self.doIcon = nil;

end

