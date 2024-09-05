void RenderInterface() {
    if (UI::Begin("Progress", null, UI::WindowFlags::NoCollapse | UI::WindowFlags::NoResize | UI::WindowFlags::NoMove)) {
        UI::Text("Progress:");

        float progress = 0.0f;

        if (Conversion::blockToBlock) {
            int x = BlockToBlock::totalBlocks - BlockToBlock::totalBlocksConverted;
            progress = 1.0f - (float(x) / float(BlockToBlock::totalBlocks));
        } else if (Conversion::blockToItem) {
            int x = BlockToItem::totalBlocks - BlockToItem::totalBlocksConverted;
            progress = 1.0f - (float(x) / float(BlockToItem::totalBlocks));
        } else if (Conversion::itemToItem) {
            int x = ItemToItem::totalItems - ItemToItem::totalItemsConverted;
            progress = 1.0f - (float(x) / float(ItemToItem::totalItems));
        }


        UI::ProgressBar(progress);
    }
}