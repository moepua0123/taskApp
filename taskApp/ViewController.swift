//
//  ViewController.swift
//  taskApp
//
//  Created by 西山萌花 on 2020/06/08.
//  Copyright © 2020 moeka.nishiyama. All rights reserved.
//

import UIKit
import RealmSwift
//ViewContorollerがUITableViewDelegate, UITableViewDataSource,UISearchBarDelegateプロトコルを参照にしているよ、という意味
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var SearchBar: UISearchBar!
    var searchResult = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    //Realm=モバイル向けデータ管理システムのこと.cocoapodsインストールでプロジェクトに導入できる
    //let realm = try! Realm() でデータベースに保存できるよーてこと
    let realm = try! Realm()  // ←追加
    
    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される
    //taskArray(一覧）は、レルムから取り出すよ、の意味。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // ←追加
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //delegateとは、他のクラスに処理を委託すること。
        tableView.delegate = self
        tableView.dataSource = self
        SearchBar.delegate = self
        SearchBar.enablesReturnKeyAutomatically = false
        
    }
    //38~69、しっくりきてないから噛み砕いてもらう
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count  // ←修正する
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    // 各セルを選択した時に、編集画面に遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil) 
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    
    //InputViewContoroller（タスクを打つ場面）に遷移する
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        //102~
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    //戻ってきた時に再構築される
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_searchBar: UISearchBar) {
        
        //categoryの中からサーチバーに書かれたテキストを検索するよのとき。
        let predicate = NSPredicate(format:  "category = %@",_searchBar.text!)
        //taskArray（一覧）に検索結果を代入して、Table Viewを再構築する
        taskArray = realm.objects(Task.self) .filter(predicate)//ここでpredicateをフィルターにするために、１２６が必要というわけ。
        //tableViewにデータ表示するよって意味
        
        tableView.reloadData()
    }
    //キャンセルボタンを押された時に、条件なし＝全てのタスクが出るように、TableViewを再構築する
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        //キャンセルした時に、まだ検索条件がついたやつが表示されてたらだるい。なので、ここでなんの条件もない全部のタスクを表示してあげる
        taskArray = realm.objects(Task.self)
        tableView.reloadData()//それで、再構築。
        
    }
    
}
