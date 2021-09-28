MailInfo = class("MailInfo");

function MailInfo:New(data)
    self = { };
    setmetatable(self, { __index = MailInfo });
    self:_Init(data);
    return self;
end

function MailInfo:_Init(data)
    --{id:String,ti:标题,st:0未读 1 已读 2附件已提取,iah:0无附件 1 有附件,d：Date}
    self.id = data.id;
    self.title = data.ti;
    self.status = data.st;
    self.annex = data.iah;
    self.time = data.d;
end
