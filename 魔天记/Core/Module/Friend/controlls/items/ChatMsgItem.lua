ChatMsgItem = class("ChatMsgItem", UIItem);

function ChatMsgItem:New()
    self = { };
    setmetatable(self, { __index = ChatMsgItem });
    return self
end

function ChatMsgItem:Init(gameObject)

    self.gameObject = gameObject
    self.gameObject_tf = UIUtil.GetComponent(self.gameObject, "Transform");


    self.left = UIUtil.GetChildByName(self.gameObject, "Transform", "left");
    self.right = UIUtil.GetChildByName(self.gameObject, "Transform", "right");

    self.timeTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "timeTxt");

    self.left_heroIcon = UIUtil.GetChildByName(self.left, "UISprite", "heroIcon");
    self.left_chattxtBg = UIUtil.GetChildByName(self.left, "UISprite", "chattxtBg");
    self.left_chatTxt = UIUtil.GetChildByName(self.left, "UILabel", "chatTxt");
    self.left_temTxt = UIUtil.GetChildByName(self.left, "UILabel", "temTxt");

    self.right_heroIcon = UIUtil.GetChildByName(self.right, "UISprite", "heroIcon");
    self.right_chattxtBg = UIUtil.GetChildByName(self.right, "UISprite", "chattxtBg");
    self.right_chatTxt = UIUtil.GetChildByName(self.right, "UILabel", "chatTxt");
    self.right_chatTxtTf = UIUtil.GetChildByName(self.right, "Transform", "chatTxt");
    self.right_temTxt = UIUtil.GetChildByName(self.right, "UILabel", "temTxt");


    self.timeTxt.text = "";

end


function ChatMsgItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

-- {"msg":"dfgdfgrd","s_id":"20102690","c":4,"k":"145515" , "t":1,"time":"2016-05-30 11:17:07","s_name":"宇文英基"}
function ChatMsgItem:SetData(d)

    self.chatData = d;

    local res_h = 130;

    local myHero = HeroController.GetInstance();
    local mydata = myHero.info;
    local my_id = "" .. mydata.id;


    if my_id ~= d.s_id then

        self.left_heroIcon.spriteName = d.k;
        self.left_chatTxt.text = d.msg;


        self.left.gameObject:SetActive(true);
        self.right.gameObject:SetActive(false);

        local txt_height = self.left_chatTxt.height;
        if txt_height > 41 then
            res_h = txt_height + 50;
        else
            res_h = 70;
        end


        if txt_height < 21 then
            self.left_temTxt.text = d.msg;
            local width = self.left_temTxt.width;
            self.left_chattxtBg.width = width + 60;
        else
            self.left_chattxtBg.width = 360;
        end

        self.left_chattxtBg.height = txt_height + 10;

    else

        self.right_heroIcon.spriteName = d.k;
        self.right_chatTxt.text = d.msg;

        Util.SetLocalPos(self.right_chatTxtTf, -80, 25, 0)

        --        self.right_chatTxtTf.localPosition = Vector3.New(-80, 25, 0);

        self.left.gameObject:SetActive(false);
        self.right.gameObject:SetActive(true);


        local txt_height = self.right_chatTxt.height;

        if txt_height > 41 then
            res_h = txt_height + 50;
        else
            res_h = 70;
        end

        if txt_height < 21 then
            self.right_temTxt.text = d.msg;
            local width = self.right_temTxt.width;
            self.right_chattxtBg.width = width + 60;
            Util.SetLocalPos(self.right_chatTxtTf, 210 - width, 25, 0)

            --            self.right_chatTxtTf.localPosition = Vector3.New(210 - width, 25, 0);

        else
            self.right_chattxtBg.width = 350;

        end

        self.right_chattxtBg.height = txt_height + 10;

    end

    if d.needShowTime then
        self.timeTxt.text = d.time;
        res_h = res_h + 30;
    else
        self.timeTxt.text = "";
    end

    self:SetActive(true);

    return res_h + 20;

end


function ChatMsgItem:SetPos(y)
    Util.SetLocalPos(self.gameObject_tf, 0, y, 0)

    --    self.gameObject_tf.localPosition = Vector3.New(0, y, 0);

end

function ChatMsgItem:_Dispose()


    self.gameObject = nil;
    self.gameObject_tf = nil;


    self.left = nil;
    self.right = nil;

    self.timeTxt = nil;

    self.left_heroIcon = nil;
    self.left_chattxtBg = nil;
    self.left_chatTxt = nil;
    self.left_temTxt = nil;

    self.right_heroIcon = nil;
    self.right_chattxtBg = nil;
    self.right_chatTxt = nil;
    self.right_chatTxtTf = nil;
    self.right_temTxt = nil;


end