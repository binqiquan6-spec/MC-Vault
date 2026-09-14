# 物品合成与获取表

文档状态：v0.1 规格冻结候选  
适用范围：Bonded Companions v1 的全部新增可获得物品

## 1. 阅读方式

- 配方按工作台 3×3，从左到右、从上到下书写，三行之间用斜杠分隔。
- 下划线表示空格；每个配方默认产出 1 件。
- 无方向意义的有序配方允许水平镜像。
- “保留组件升级”表示保留自定义名称、附魔及剩余耐久比例；这是为了让迭代装备不抹掉玩家投入。
- 有内容的货运容器不能参与其他配方。需要作为材料时，只接受完全空的容器。

## 2. 通用伙伴物品

### 2.1 目标名单册

- 物品 ID：bonded_companions:target_ledger
- 配方：PKP / KBR / PCP
- 符号：P 纸，K 墨囊，B 书，R 红石粉，C 指南针
- 合计：纸 4、墨囊 2、书 1、红石粉 1、指南针 1
- 设计理由：指南针代表锁定对象，红石承担规则状态；成本足以阻止开局无代价批量制作，但不会把核心玩法锁到后期。

### 2.2 带刺项圈

- 物品 ID：bonded_companions:spiked_collar
- 配方：NCN / L_L / NLN
- 符号：N 铁粒，C 锁链，L 皮革
- 合计：铁粒 4、锁链 1、皮革 3

### 2.3 宠物收纳袋

- 物品 ID：bonded_companions:pet_satchel
- 配方：LSL / LCL / L_L
- 符号：L 皮革，S 线，C 箱子
- 合计：皮革 6、线 1、箱子 1
- 容量：9 格

### 2.4 美西螈背带

- 物品 ID：bonded_companions:axolotl_harness
- 配方：SPS / LML / LPL
- 符号：S 线，P 海晶碎片，L 皮革，M 黏液球
- 合计：线 2、海晶碎片 2、皮革 4、黏液球 1

### 2.5 青金护符

- 物品 ID：bonded_companions:lapis_talisman
- 配方：SLS / LGL / LLL
- 符号：S 线，L 青金石，G 金粒
- 合计：线 2、青金石 6、金粒 1

## 3. 衔月刃

### 3.1 铁、金与钻石衔月刃

- 物品 ID：bonded_companions:iron_moonfang_blade、gold_moonfang_blade、diamond_moonfang_blade
- 通用配方：MM_ / _C_ / _H_
- 符号：M 对应材料的铁锭、金锭或钻石，C 锁链，H 兔子皮
- 合计：对应材料 2、锁链 1、兔子皮 1
- 三个材料版本分别制作，不允许混用材料。

### 3.2 下界合金衔月刃

- 物品 ID：bonded_companions:netherite_moonfang_blade
- 工作站：锻造台
- 模板：下界合金升级锻造模板
- 基础物品：钻石衔月刃
- 添加材料：下界合金锭
- 升级保留：名称、附魔与耐久比例

## 4. 傀儡物品

### 4.1 控制核心

- 物品 ID：bonded_companions:control_core
- 配方：ROR / UKU / RQR
- 符号：R 红石粉，O 指南针，U 铜锭，K 红石比较器，Q 下界石英
- 合计：红石粉 4、指南针 1、铜锭 2、红石比较器 1、下界石英 1

### 4.2 雪傀儡保温皮套

- 物品 ID：bonded_companions:snow_golem_leather_wrap
- 配方：LWL / S_S / LWL
- 符号：L 皮革，W 任意羊毛，S 线
- 合计：皮革 4、羊毛 2、线 2

### 4.3 雪傀儡铁制护架

- 物品 ID：bonded_companions:snow_golem_iron_brace
- 配方：_I_ / IXI / _I_
- 符号：I 铁锭，X 雪傀儡保温皮套
- 合计：铁锭 4、雪傀儡保温皮套 1
- 类型：保留组件升级

### 4.4 雪傀儡钻石凝霜甲片

- 物品 ID：bonded_companions:snow_golem_diamond_frost_plate
- 配方：DID / IXI / DID
- 符号：D 钻石，I 浮冰，X 雪傀儡铁制护架
- 合计：钻石 4、浮冰 4、雪傀儡铁制护架 1
- 类型：保留组件升级

### 4.5 雪傀儡下界合金熔芯甲片

- 物品 ID：bonded_companions:snow_golem_netherite_core_plate
- 工作站：锻造台
- 模板：下界合金升级锻造模板
- 基础物品：雪傀儡钻石凝霜甲片
- 添加材料：下界合金锭
- 升级保留：名称、附魔与耐久比例

### 4.6 铁傀儡皮革缓冲层

- 物品 ID：bonded_companions:iron_golem_leather_padding
- 配方：LIL / LCL / LIL
- 符号：L 皮革，I 铁锭，C 锁链
- 合计：皮革 6、铁锭 2、锁链 1

### 4.7 铁傀儡铁质补强板

- 物品 ID：bonded_companions:iron_golem_iron_reinforcement
- 配方：III / IXI / III
- 符号：I 铁锭，X 铁傀儡皮革缓冲层
- 合计：铁锭 8、铁傀儡皮革缓冲层 1
- 类型：保留组件升级

### 4.8 铁傀儡钻石强化板

- 物品 ID：bonded_companions:iron_golem_diamond_reinforcement
- 配方：D_D / _X_ / D_D
- 符号：D 钻石，X 铁傀儡铁质补强板
- 合计：钻石 4、铁傀儡铁质补强板 1
- 类型：保留组件升级

### 4.9 铁傀儡下界合金强化板

- 物品 ID：bonded_companions:iron_golem_netherite_reinforcement
- 工作站：锻造台
- 模板：下界合金升级锻造模板
- 基础物品：铁傀儡钻石强化板
- 添加材料：下界合金锭
- 升级保留：名称、附魔与耐久比例

## 5. 货运物品

### 5.1 马用驮箱

- 物品 ID：bonded_companions:horse_pack_chest
- 配方：LCL / _I_ / LCL
- 符号：L 皮革，C 箱子，I 铁锭
- 合计：皮革 4、箱子 2、铁锭 1
- 容量：18 格

### 5.2 驴用驮架

- 物品 ID：bonded_companions:donkey_pack_frame
- 配方：LCL / IBI / LCL
- 符号：L 皮革，C 箱子，I 铁锭，B 木桶
- 合计：皮革 4、箱子 2、铁锭 2、木桶 1
- 容量：27 格

### 5.3 骡用分拣驮袋

- 物品 ID：bonded_companions:mule_sorting_pannier
- 配方：LCL / RHK / LCL
- 符号：L 皮革，C 箱子，R 红石粉，H 漏斗，K 红石比较器
- 合计：皮革 4、箱子 2、红石粉 1、漏斗 1、红石比较器 1
- 容量：18 格，另有 3 个不储存物品的幽灵过滤位

### 5.4 骆驼商旅架

- 物品 ID：bonded_companions:camel_caravan_rack
- 配方：CLC / BIB / CLC
- 符号：C 箱子，L 皮革，B 竹板，I 铁锭
- 合计：箱子 4、皮革 2、竹板 2、铁锭 1
- 容量：36 格

### 5.5 耐热驮袋

- 物品 ID：bonded_companions:heatproof_pannier
- 配方：LML / WPW / _S_
- 符号：L 皮革，M 岩浆膏，W 下界疣，P 烈焰粉，S 空的宠物收纳袋
- 合计：皮革 2、岩浆膏 2、下界疣 2、烈焰粉 1、空宠物收纳袋 1
- 容量：18 格
- 限制：收纳袋中存在物品时配方无输出。

### 5.6 货运拴桩

- 方块 ID：bonded_companions:cargo_hitching_post
- 配方：ICI / RFR / SKS
- 符号：I 铁锭，C 锁链，R 红石粉，F 任意木制栅栏，S 平滑石台阶，K 红石比较器
- 合计：铁锭 2、锁链 1、红石粉 2、木制栅栏 1、平滑石台阶 2、红石比较器 1

## 6. 山羊装备

### 6.1 铁冲角

- 物品 ID：bonded_companions:iron_ram_headpiece
- 配方：ICI / LIL / ___
- 符号：I 铁锭，C 锁链，L 皮革
- 合计：铁锭 3、锁链 1、皮革 2

### 6.2 钻石冲角

- 物品 ID：bonded_companions:diamond_ram_headpiece
- 配方：D_D / _X_ / ___
- 符号：D 钻石，X 铁冲角
- 合计：钻石 2、铁冲角 1
- 类型：保留组件升级

### 6.3 下界合金冲角

- 物品 ID：bonded_companions:netherite_ram_headpiece
- 工作站：锻造台
- 模板：下界合金升级锻造模板
- 基础物品：钻石冲角
- 添加材料：下界合金锭
- 升级保留：名称、附魔与耐久比例

### 6.4 缓冲背带

- 物品 ID：bonded_companions:impact_harness
- 配方：SWS / LLL / LWL
- 符号：S 线，W 任意羊毛，L 皮革
- 合计：线 2、羊毛 2、皮革 5

## 7. 水生与探索装备

### 7.1 海豚回声背带

- 物品 ID：bonded_companions:echo_harness
- 配方：UPU / LNL / LPL
- 符号：U 铜锭，P 海晶砂粒，L 皮革，N 鹦鹉螺壳
- 合计：铜锭 2、海晶砂粒 2、皮革 4、鹦鹉螺壳 1

### 7.2 炽足兽热力皮夹

- 物品 ID：bonded_companions:thermal_jacket
- 配方：LML / SBM / LLL
- 符号：L 皮革，M 岩浆膏，S 线，B 烈焰粉
- 合计：皮革 5、岩浆膏 2、线 1、烈焰粉 1

### 7.3 嗅探兽远行背带

- 物品 ID：bonded_companions:expedition_harness
- 配方：LUL / SBU / LLL
- 符号：L 皮革，U 铜锭，S 线，B 刷子
- 合计：皮革 5、铜锭 2、线 1、刷子 1

### 7.4 种子袋

- 物品 ID：bonded_companions:seed_pouch
- 配方：SLS / LCL / _L_
- 符号：S 线，L 皮革，C 箱子
- 合计：线 2、皮革 4、箱子 1
- 容量：9 格，仅接受种子及数据标签允许的植物繁殖材料

## 8. 沿用原版获取的物品

下列物品不新增重复配方：

- 狼铠：沿用原版犰狳鳞甲配方、修复和破损规则。
- 马铠：沿用原版制作或战利品来源；本模组只扩展可附魔性。
- 鞍、牵绳、箱子、桶及各类基础材料：沿用原版或整合包已有配方。
- 附魔书：不提供直接工作台合成。

## 9. 附魔获取表

| 附魔类别 | 获取方式 | 备注 |
|---|---|---|
| 普通专属附魔 | 对适用装备使用附魔台；结构战利品中的随机附魔书 | 不默认塞入图书管理员交易池，避免污染大型整合包交易 |
| 不屈 | 古城、林地府邸、不祥试炼宝库低概率附魔书 | 宝藏附魔；不从附魔台出现 |
| 共生回响 | 钓鱼宝藏、海底废墟、大师级渔夫交易 | 交易基线：24–40 绿宝石 + 书，最多 2 次 |
| 归魂 | 林地府邸、古城、要塞图书馆、大师级牧师交易 | 交易基线：32–48 绿宝石 + 书，最多 1 次 |

交易价格、权重和宝箱概率属于平衡数据，不写死在行为代码中。整合包验证时重点检查村民交易池是否被其他模组替换；若被替换，保留宝箱来源并通过兼容数据注入交易。

## 10. 配方实现约束

- 常规配方使用原版 JSON 配方和通用材料标签，允许整合包同类材料。
- 铁、钻石阶段的补强与冲角升级统一使用 `bonded_companions:component_preserving_shaped`。每个配方用 `base` 字段指明被升级装备；输出继承其自定义名称、附魔与其他组件，并按已消耗耐久比例换算到新装备的最大耐久。
- 下界合金阶段使用原版锻造流程。
- 配方查看器中必须能看到所有常规与升级配方；若自定义升级配方不能被目标整合包的配方查看器识别，则在发布候选前补兼容显示。
- 装有物品的收纳袋、驮箱、驮架、驮袋和种子袋都不得成为合成原料。
