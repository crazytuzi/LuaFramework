local model_effect={
[1]={1,'n_mgz004','Bip001__Prop1','buff_w_n_mgz004_B_LH'},
[2]={2,'partner_08','Bone007','buff_w_partner_08_Bone007'},
[3]={3,'partner_10','Bone016','buff_w_partner_10_Bone016'},
[4]={4,'partner_06','Bone008','buff_w_partner_06_Bone008'},
[5]={5,'partner_07','B_RH','buff_w_partner_07_B_RH'},
[6]={6,'partner_04','B_LH','buff_w_partner_04_B_LH'},
[7]={7,'n_mgz002','Bone026','buff_w_n_mgz002_Bone026'},
[8]={8,'partner_09','Bone057','buff_w_partner_09_Bone057'},
[9]={9,'partner_09','Bone057___mirrored____','buff_w_partner_09_Bone057'},
[10]={10,'partner_09','Bone059','buff_w_partner_09_Bone057'},
[11]={11,'n_mgz003','Bip001__Prop1','buff_w_n_mgz003_Bip001_Prop1'},
[12]={12,'partner_05','Bone013','buff_w_partner_05_Bone013'},
[13]={13,'n_mgz001','Bone015','buff_w_n_mgz001_Bone015'},
[14]={14,'n_mgz001','Bone018','buff_w_n_mgz001_Bone015'},
[15]={15,'n_mgz001','Bone022','buff_w_n_mgz001_Bone022'},
[16]={16,'partner_13','Bone014','buff_w_partner_13_Bone014'},
[17]={17,'partner_16','Bone013','buff_w_partner_16_Bone013'},
[18]={18,'partner_12','Bip001__Spine1','buff_w_partner_12_Bip001_Spine1'}
}
local ks={id=1,partner_id=2,joint=3,effect_id=4}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(model_effect)do setmetatable(v,base)end base.__metatable=false
return model_effect
