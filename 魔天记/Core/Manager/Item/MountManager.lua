MountManager = { }

MountManager.login_mount = nil;

MountManager.TYPE_F_MOUNT = 1; -- 飞行载具
MountManager.TYPE_L_MOUNT = 2; -- 战斗载具

function MountManager.Init(login_mount)
    MountManager.mountConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MOUNT)
 

    MountManager.SetLoginData(login_mount)

end


function MountManager.SetLoginData(data)

    --[[
    {id:载具id,rt:剩余秒数 0表示一直存在,rid:飞行载具路径,per：飞行载具进度}
    ]]
    MountManager.login_mount = data;

    if MountManager.login_mount.id == 0 then
        MountManager.login_mount = nil;
    end

end



function MountManager.GetMountConfigById(id)
    return ConfigManager.Clone(self.mountConfig[id])
end

 
--[[
 登录 并进入场景后， 需要检测自己 是否 还在 载具状态

 {id:载具id,rt:剩余秒数 0表示一直存在,rid:飞行载具路径,per：飞行载具进度}
]]
function MountManager.LoginCheckMount()

    --log("------------------------MountManager.LoginCheckMount------------------------");

    if MountManager.login_mount ~= nil then
        local mount_id = MountManager.login_mount.id;

      --  mount_id = 862100;

        local mcf = ConfigManager.GetMount(mount_id); 

        if mcf.type == MountManager.TYPE_F_MOUNT then

            local rid = MountManager.login_mount.rid;
            local per = MountManager.login_mount.per;

            if rid == nil or rid == "" then
                rid = "861100";
            end

            if per == nil then
                per = 5000;
            end

            HeroController:GetInstance():OnMountByRid(mount_id, rid,false,per);

        elseif mcf.type == MountManager.TYPE_L_MOUNT then
           
          local rt = MountManager.login_mount.rt;

          HeroController:GetInstance():OnMountLang(mount_id,rt);

        end


    end

end