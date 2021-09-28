require "Core.Info.FightRoleInfo";


MountInfo = class("MountInfo", FightRoleInfo);
MountInfo.skill = 0;
MountInfo.type = 0;
MountInfo.bar_num = 1;
MountInfo.search_type = 0;
MountInfo.patrol = 0;
MountInfo.search = 0;
MountInfo.chase = 0;
MountInfo.vision = 0;
MountInfo.exp = 0;
MountInfo.money = 0;

function MountInfo:New(mount_id)
    self = { };
    setmetatable(self, { __index = MountInfo });
    self:_InitDefAttribute();

    self.baseSkills = {};
    self.skills = {};
    self:_Init(mount_id);
    return self;
end

function MountInfo:_Init(mount_id)
   
   local mountCf =  ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MOUNT);
   local bInfo  = mountCf[mount_id];
    
    if (bInfo) then
     
        ConfigManager.copyTo(bInfo, self);

        self:_InitDefaultSkills();
        self.kind = bInfo.id;
        self.hp = self.hp_max;
        self.mp = self.mp_max;

    end
end
