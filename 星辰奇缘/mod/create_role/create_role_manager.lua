-- demo
CreateRoleManager = CreateRoleManager or BaseClass(BaseManager)

function CreateRoleManager:__init()
    if CreateRoleManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    CreateRoleManager.Instance = self;
    self:InitHandler()

    self.model = CreateRoleModel.New()

    self:InitHandler()
end

function CreateRoleManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function CreateRoleManager:InitHandler()
end

--创建角色
function CreateRoleManager:do_create_role(_name, _gender,_classes)
    LoginManager.Instance:send1110(_name, _gender, _classes)
end