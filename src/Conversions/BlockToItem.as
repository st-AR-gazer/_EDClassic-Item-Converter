namespace BlockToItem {
    Utils@ utils;
    Conversion@ conv;

    int totalBlocks = 0;
    int totalBlocksConverted = 0;

    void Init() {
        log("Initializing BlockToItem.", LogLevel::Info, 9, "Init");

        @utils = Utils();
        @conv = Conversion();

        ConversionPreparation();
    }

    void ConversionPreparation() {
        log("Converting block to item.", LogLevel::Info, 18, "ConversionPreparation");
        
        CGameCtnApp@ app = GetApp();
        CGameCtnEditorCommon@ editor = cast<CGameCtnEditorCommon@>(app.Editor);
        CGameEditorPluginMapMapType@ pmt = editor.PluginMapType;
        CGameEditorGenericInventory@ inventory = pmt.Inventory;

        CGameCtnArticleNodeDirectory@ blocksNode = cast<CGameCtnArticleNodeDirectory@>(inventory.RootNodes[0]);
        totalBlocks = utils.CountBlocks(blocksNode, false, true);
        ExploreNode(blocksNode);
    }

    void ExploreNode(CGameCtnArticleNodeDirectory@ parentNode, string _folder = "") {
        for (uint i = 0; i < parentNode.ChildNodes.Length; i++) {
            auto node = parentNode.ChildNodes[i];
            if (node.IsDirectory) {
                ExploreNode(cast<CGameCtnArticleNodeDirectory@>(node), _folder + node.Name + "/");
            } else {
                auto ana = cast<CGameCtnArticleNodeArticle@>(node);
                if (ana.Article is null || ana.Article.IdName.ToLower().EndsWith("customblock")) {
                    log("Skipping block " + ana.Name + " because it's a custom block.", LogLevel::Info, 38, "ExploreNode");
                    continue;
                }
                string itemSaveLocation = "Nadeo/" + "VanillaBlockToCustomItem/" + _folder + ana.Name + ".Item.Gbx";
                totalBlocksConverted++;
                log("Converting block " + ana.Name + " to item.", LogLevel::Info, 43, "ExploreNode");
                string fullItemSaveLocation = IO::FromUserGameFolder("Items/" + itemSaveLocation); // Changed to "Items/" for items

                print(fullItemSaveLocation);

                if (IO::FileExists(fullItemSaveLocation)) {
                    log("Item " + itemSaveLocation + " already exists. Skipping.", LogLevel::Info, 47, "ExploreNode");
                } else {
                    auto block = cast<CGameCtnBlockInfo@>(ana.Article.LoadedNod);

                    if (block is null) {
                        log("Block " + ana.Name + " is null. Skipping.", LogLevel::Info, 52, "ExploreNode");
                        continue;
                    }

                    if (string(block.Name).ToLower().Contains("water")) {
                        log("Water cannot be converted to a custom block/item. Skipping.", LogLevel::Info, 57, "ExploreNode");
                        continue;
                    }

                    if (utils.IsBlacklisted(block.Name)) {
                        log("Block " + block.Name + " is blacklisted. Skipping.", LogLevel::Info, 62, "ExploreNode");
                        continue;
                    }

                    log("Converting block " + block.Name + " to item.", LogLevel::Info, 66, "ExploreNode");
                    log("Saving item to " + itemSaveLocation, LogLevel::Info, 67, "ExploreNode");

                    conv.ConvertBlockToItem(block, itemSaveLocation);
                }
            }
        }
    }

    class Conversion {
        int2 button_Icon = int2(445, 417);
        int2 button_DirectionIcon = int2(985, 550);

        void ConvertBlockToItem(CGameCtnBlockInfo@ blockInfo, const string &in itemSaveLocation) {
            log("Converting block to item.", LogLevel::Info, 80, "ConvertBlockToItem");

            auto app = GetApp();
            auto editor = cast<CGameCtnEditorCommon@>(app.Editor);
            auto pmt = editor.PluginMapType;

            // pmt.RemoveAll();
            
            yield();
            
            // pmt.PlaceMode = CGameEditorPluginMap::EPlaceMode::FreeBlock;
            // pmt.PlaceMode = CGameEditorPluginMap::EPlaceMode::Block;
            pmt.PlaceMode = CGameEditorPluginMap::EPlaceMode::GhostBlock;

            yield();

            @pmt.CursorBlockModel = blockInfo;
            if (pmt.CursorBlockModel is null) print("CursorBlockModel is null");

            yield();


            int nBlocks = pmt.Blocks.Length;
            log("Starting to place the block: " + blockInfo.Name, LogLevel::Info, 99, "ConvertBlockToItem");
            while (pmt.Blocks.Length == uint(nBlocks)) {
                mouse.Click();
                yield();
            }

            editor.ButtonItemCreateFromBlockModeOnClick();

            yield();

            while (cast<CGameEditorItem>(app.Editor) is null) {
                @editor = cast<CGameCtnEditorCommon@>(app.Editor);
                if (editor !is null && editor.PickedBlock !is null && editor.PickedBlock.BlockInfo.IdName == blockInfo.Name) {
                    log("Clicking to confirm selection.", LogLevel::Info, 111, "ConvertBlockToItem");
                    mouse.Click();
                }
                yield();
            }

            CGameEditorItem@ editorItem = cast<CGameEditorItem>(app.Editor);
            editorItem.IdName = blockInfo.Name;
 
            editorItem.PlacementParamGridHorizontalSize = 32;
            editorItem.PlacementParamGridVerticalSize = 8;
            editorItem.PlacementParamFlyStep = 8;

            log("Clicking the button to set the icon.", LogLevel::Info, 124, "ConvertBlockToItem");
            mouse.Move(button_Icon);
            mouse.Click();

            yield();

            log("Clicking the button to set the direction icon.", LogLevel::Info, 129, "ConvertBlockToItem");
            mouse.Move(button_DirectionIcon);
            mouse.Click();

            yield();

            log("Saving item to: " + itemSaveLocation, LogLevel::Info, 134, "ConvertBlockToItem");
            editorItem.FileSaveAs();

            yield(3);

            app.BasicDialogs.String = itemSaveLocation;

            yield();

            app.BasicDialogs.DialogSaveAs_OnValidate();

            yield();

            app.BasicDialogs.DialogSaveAs_OnValidate();
            
            yield();

            cast<CGameEditorItem>(app.Editor).Exit();

            while (cast<CGameEditorItem>(app.Editor) !is null) {
                yield();
            }

            yield();

            @editor = cast<CGameCtnEditorCommon@>(app.Editor);
            @pmt = editor.PluginMapType;
            pmt.Undo();

            // pmt.RemoveAll();
        }
    }

    class Utils {
        bool IsBlacklisted(const string &in blockName) {
            for (uint i = 0; i < blockToItemBlacklist.Length; i++) {
                if (blockName.Contains(blockToItemBlacklist[i])) {
                    return true;
                }
            }
            return false;
        }

        int CountBlocks(CGameCtnArticleNodeDirectory@ parentNode, bool justNadeoBlocks = true, bool containsWater = false) {
            int count = 0;
            for(uint i = 0; i < parentNode.ChildNodes.Length; i++) {
                CGameCtnArticleNode@ node = parentNode.ChildNodes[i];
                if(node.IsDirectory) {
                    count += CountBlocks(cast<CGameCtnArticleNodeDirectory@>(node), justNadeoBlocks);
                } else {
                    CGameCtnBlock@ block = cast<CGameCtnBlock@>(node);
                    if (justNadeoBlocks && block.BlockInfo.Name.Contains("customblock")) {
                        continue;
                    }
                    count++;
                }
            }
            return count;
        }

        int BlocksLeftToConvert() {
            return totalBlocks - totalBlocksConverted;
        }
    }
}
