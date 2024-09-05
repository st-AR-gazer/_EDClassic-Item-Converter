namespace ItemToItem {

    Utils@ utils;
    Conversion@ conv;

    int totalItems = 0;
    int totalItemsConverted = 0;

    void Init() {
        log("Initializing ItemToItem.", LogLevel::Info, 10, "Init");

        utils = Utils();
        conv = Conversion();

        ConversionPreparation();
    }

    void ConversionPreparation() {
        log("Converting item to item.", LogLevel::Info, 19, "ConversionPreparation");

        CGameCtnApp@ app = GetApp();
        CGameCtnEditorCommon@ editor = cast<CGameCtnEditorCommon@>(app.Editor);
        CGameEditorPluginMapMapType@ pmt = editor.PluginMapType;
        CGameEditorGenericInventory@ inventory = pmt.Inventory;

        CGameCtnArticleNodeDirectory@ itemsNode = cast<CGameCtnArticleNodeDirectory@>(inventory.RootNodes[1]); // set to 1 as 0 is the blocks node // Must be tested if it is correct though xdd
        totalItems = utils.CountBlocks(itemsNode);
        ExploreNode(itemsNode);
    }

    void ExploreNode(CGameCtnArticleNodeDirectory@ parentNode, string _folder = "") {
        for (uint i = 0; i < parentNode.ChildNodes.Length; i++) {
            CGameCtnArticleNode@ node = parentNode.ChildNodes[i];
            if (node.IsDirectory) {
                ExploreNode(cast<CGameCtnArticleNodeDirectory@>(node), _folder + node.Name + "/");
            } else {
                auto ana = cast<CGameCtnArticleNodeArticle@>(node);
                if (ana.Article is null || ana.Article.IdName.ToLower().EndsWith("customitem")) {
                    log("Skipping item " + ana.Name + " because it's a custom item.", LogLevel::Info, 39, "ExploreNode");
                    continue;
                }
                string itemSaveLocation = "VanillaItemToCustomItem/" + _folder + ana.Name + ".Item.Gbx";
                totalItemsConverted++;
                log("Converting item " + ana.Name + " to item.", LogLevel::Info, 44, "ExploreNode");
                string fullItemSaveLocation = IO::FromUserGameFolder("Items/" + itemSaveLocation); // Changed to "Items/" for items

                if (IO::FileExists(fullItemSaveLocation)) {
                    log("Item " + itemSaveLocation + " already exists. Skipping.", LogLevel::Info, 48, "ExploreNode");
                } else {
                    auto item = cast<CGameCtnBlockInfo@>(ana.Article.LoadedNod);

                    if (item is null) {
                        log("Item " + ana.Name + " is null. Skipping.", LogLevel::Info, 53, "ExploreNode");
                        continue;
                    }

                    if (string(item.Name).ToLower().Contains("water")) {
                        log("Water cannot be converted to a custom block/item. Skipping.", LogLevel::Info, 58, "ExploreNode");
                        continue;
                    }

                    if (utils.IsBlacklisted(item.Name)) {
                        log("Item " + item.Name + " is blacklisted. Skipping.", LogLevel::Info, 63, "ExploreNode");
                        continue;
                    }

                    conv.ConvertItemToItem(item, itemSaveLocation);
                }
            }
        }
    }

    class Conversion {
        void ConvertItemToItem(CGameCtnBlockInfo@ block, const string &in itemSaveLocation) {
            
    
        }
    }

    class Utils {
        bool IsBlacklisted(const string &in itemName) {
            for (uint i = 0; i < itemToItemBlacklist.Length; i++) {
                if (itemName == itemToItemBlacklist[i]) {
                    return true;
                }
            }
            return false;
        }

        int CountBlocks(CGameCtnArticleNodeDirectory@ parentNode) {
            int count = 0;
            for (uint i = 0; i < parentNode.ChildNodes.Length; i++) {
                CGameCtnArticleNode@ node = parentNode.ChildNodes[i];
                if (node.IsDirectory) {
                    count += CountBlocks(cast<CGameCtnArticleNodeDirectory@>(node));
                } else {
                    count++;
                }
            }
            return count;
        }

        int ItemsLeftToConvert() {
            return totalItems - totalItemsConverted;
        }
}
}











// get an offset from class name & member name
uint16 GetOffset(const string &in className, const string &in memberName) {
    // throw exception when something goes wrong.
    auto ty = Reflection::GetType(className);
    auto memberTy = ty.GetMember(memberName);
    if (memberTy.Offset == 0xFFFF) throw("Invalid offset: 0xFFFF");
    return memberTy.Offset;
}


    namespace OpenIEOffsets {
        // 0x1008 - 1 in ieditor for block and item
        // 0x1150 - 0x1138 = 0x18
        // 0x1150 - set to 1 to enter item editor
        // 0x1158: ptr to edited item from last
        // 0x1160 - set to 1 when in block mode
        // 0x1190: ptr to edited item (+0x40) from last (while in ieditor block mode this points to ItemModel)
        // 0x1198: ptr to edited block (+0x48) from last (while in ieditor block mode this points to CGameCtnBlock)
        // 0x11b8: ptr to fid (?? of item model)
        // 0x11c0: ptr to orig item model (seems like a duplicate is created in item editor)
        // 0x648: ptr to picked item; 0x628 item cursor
        // 0xA28: nat3 coords of picked item
        auto o1138 = GetOffset("CGameCtnEditorFree", "ColoredCopperPrice");
        auto o1150 = o1138 + 0x18;
        auto o1158 = o1138 + 0x20;
        auto o1160 = o1138 + 0x28;
        auto o1190 = o1138 + 0x58;
        auto o1198 = o1138 + 0x60;
    }

    // CGameCtnAnchoredObject
    void OpenItemEditor(CGameCtnEditorFree@ editor, CGameCtnAnchoredObject@ nodToEdit) {
        if (editor is null) return;
        Dev::SetOffset(editor,  OpenIEOffsets::o1150, uint8(1));
        Dev::SetOffset(editor, OpenIEOffsets::o1158, nodToEdit);
    }

    void OpenItemEditor(CGameCtnEditorFree@ editor, CGameCtnBlock@ nodToEdit) {
        bool blockEditor = true;
        if (editor is null) return;
        Dev::SetOffset(editor,  OpenIEOffsets::o1150, uint8(1));
        Dev::SetOffset(editor, OpenIEOffsets::o1198, nodToEdit);
        Dev::SetOffset(editor,  OpenIEOffsets::o1160, uint8(blockEditor ? 1 : 0));
    }