---
--- Created by R2D2.
--- DateTime: 2019/4/2 19:31
---

PetEvent = PetEvent or {
    ---打开主窗体
    Pet_OpenPanelEvent = "Pet.OnOpenPanel",
    ---获取到开蛋记录
    Pet_EggRecordsEvent = "Pet.OnEggRecords",
    ---推荐可用宠物
    Pet_RecommendEvent = "Pet.OnRecommend",

    -----模块级事件
    ---选中Pet
    Pet_Model_SelectPetEvent = "Pet.Model.OnSelectPet",
    ---背包中添加
    Pet_Model_AddBagPetEvent = "Pet.Model.OnAddBagPet",
    ---删除背包中的
    Pet_Model_DeleteBagPetEvent = "Pet.Model.OnDeleteBagPet",
    ---出战中的数据变化
    Pet_Model_BattlePetDataEvent = "Pet.Model.OnBattlePetData",
    ---设置Pet出战/助战
    Pet_Model_ChangeBattlePetEvent = "Pet.Model.OnChangeBattlePet",
    ---训练Pet
    Pet_Model_TrainBattlePetEvent = "Pet.Model.OnTrainBattlePet",
    ---训练升段Pet
    Pet_Model_CrossBattlePetEvent = "Pet.Model.OnCrossBattlePet",
    ---突破Pet
    Pet_Model_EvolutionBattlePetEvent = "Pet.Model.OnEvolutionBattlePet",
    ---突破退还
    Pet_Model_BackEvolutionBattlePetEvent = "Pet.Model.OnBackEvolutionBattlePet",
    ---融合Pet
    Pet_Model_ComposePetEvent = "Pet.Model.OnComposePet",
    ---分解Pet
    Pet_Model_DecomposePetEvent = "Pet.Model.OnDecomposePet",
    ---切换标签页
    Pet_Model_ReqPetPanelChangePageEvent = "Pet.Model.OnReqPetPanelChangePage",
}