import SQLite
import Foundation

class SQLiteManager {
    static let shared = SQLiteManager()
    private var db: Connection?

    private init() {
        do {

            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let databasePath = documentsDirectory.appendingPathComponent("myDatabase.sqlite").path


            db = try Connection(databasePath)

            try db?.run(UserTable.table.create(ifNotExists: true) { t in
                t.column(UserTable.id, primaryKey: true)
                t.column(UserTable.email, unique: true)
                t.column(UserTable.password)
                t.column(UserTable.name)
            })

          
            try db?.run(SessionTable.table.create(ifNotExists: true) { t in
                t.column(SessionTable.id, primaryKey: true)
                t.column(SessionTable.userId, unique: true)
                t.column(SessionTable.isLoggedIn)
            })

        } catch {
            print("Error initializing database: \(error)")
        }
    }


    func createUser(email: String, password: String, name: String) {
        do {
            let insertUser = UserTable.table.insert(
                UserTable.email <- email,
                UserTable.password <- password,
                UserTable.name <- name
            )

            try db?.run(insertUser)
        } catch {
            print("Error inserting user: \(error)")
        }
    }


    func loginUser(email: String, password: String) -> Bool {
        do {
            let query = UserTable.table.filter(
                UserTable.email == email && UserTable.password == password
            )

            if let user = try db?.pluck(query) {

                createSession(userId: user[UserTable.id], isLoggedIn: true)
                return true
            }

        } catch {
            print("Error querying user: \(error)")
        }

        return false
    }

    func logoutUser() {
        do {
            let updateSession = SessionTable.table.update(
                SessionTable.isLoggedIn <- false
            )

            try db?.run(updateSession)
        } catch {
            print("Error updating session: \(error)")
        }
    }

    private func createSession(userId: Int64, isLoggedIn: Bool) {
        do {
            let insertSession = SessionTable.table.insert(
                SessionTable.userId <- userId,
                SessionTable.isLoggedIn <- isLoggedIn
            )

            try db?.run(insertSession)
        } catch {
            print("Error creating session: \(error)")
        }
    }
}


struct UserTable {
    static let table = Table("User")

    static let id = Expression<Int64>("id")
    static let email = Expression<String>("email")
    static let password = Expression<String>("password")
    static let name = Expression<String>("name")
}

struct SessionTable {
    static let table = Table("Session")
    
    static let id = Expression<Int64>("id")
    static let userId = Expression<Int64>("userId")
    static let isLoggedIn = Expression<Bool>("isLoggedIn")
}
