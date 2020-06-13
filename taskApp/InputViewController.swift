//
//  InputViewController.swift
//  taskApp
//
//  Created by 西山萌花 on 2020/06/10.
//  Copyright © 2020 moeka.nishiyama. All rights reserved.
//

import UIKit
import RealmSwift
//タスクを打つ場面
class InputViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
   
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBOutlet weak var contentsTextView: UITextView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
//レルムに保存する
    let realm = try! Realm()
    var task: Task! 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the vie

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        titleTextField.text = task.title
        categoryTextField.text = task.category
        contentsTextView.text = task.contents
        datePicker.date = task.date
    }

    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.category = self.categoryTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: .modified)
        }
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        if task.category == "" {
            content.title = "(カテゴリーなし)"
        } else {
            content.title = task.contents
        }
        
        content.sound = UNNotificationSound.default

        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)

        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
