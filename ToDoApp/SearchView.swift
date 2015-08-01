import UIKit

class SearchView: HeaderView, UISearchBarDelegate{

    private var searchBar : UISearchBar? // 検索バー
    var onSearch:((String)->Void)? // 検索文字列が変化した際のイベントハンドラ
    
    required init(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)

        // サブビューの検索
        for childView in subviews {
            if let v = childView as? UISearchBar {
                searchBar = v
            }
        }
        // 検索バーのdelegate指定
        searchBar?.delegate = self

    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if onSearch != nil {
            onSearch!(searchText)
        }
    }
    


}
