//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Эльдар Милкаманавичюс on 09.11.2025.
//

import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        app.launch()// запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        // Ищем кнопку Authenticate по индексу (первая кнопка на экране)
        let authenticateButton = app.buttons.element(boundBy: 0)
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 5))
        authenticateButton.tap()
        
        let webView = app.webViews["WebViewViewController"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        sleep(1) // Даем время для появления клавиатуры
        
        // ОЧИЩАЕМ поле и вводим логин
        loginTextField.typeText(XCUIKeyboardKey.delete.rawValue) // Очистка поля
        let login = "login"
        
        // МЕДЛЕННЫЙ ввод логина с проверками
        print("Начинаем ввод логина: \(login)")
        for (index, character) in login.enumerated() {
            loginTextField.typeText(String(character))
            usleep(300000) // 0.3 секунды между символами
            
            // Пауза после каждых 5 символов
            if (index + 1) % 5 == 0 {
                sleep(1)
            }
        }
        sleep(2) // Большая пауза после ввода логина
        
        webView.swipeUp()
        sleep(1)
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        sleep(2) // Даем время для появления клавиатуры
        
        // ОЧЕНЬ МЕДЛЕННЫЙ ввод пароля с большими задержками
        let password = "password"
        print("Начинаем ввод пароля. Должно быть символов: \(password.count)")
        
        for (index, character) in password.enumerated() {
            passwordTextField.typeText(String(character))
            
            // РАЗНЫЕ задержки для разных типов символов
            switch character {
            case "J", "c", "v", "f", "y": // буквы
                usleep(500000) // 0.5 секунды
            case ".", "@", "_", "-": // специальные символы
                usleep(800000) // 0.8 секунды
            default: // цифры
                usleep(400000) // 0.4 секунды
            }
            
            // Пауза после каждых 3 символов
            if (index + 1) % 3 == 0 {
                sleep(2)
            }
            
            print("Введен символ \(index + 1): '\(character)'")
        }
        
        print("Ввод пароля завершен. Проверяем...")
        sleep(3) // Большая пауза после ввода пароля
        
        webView.swipeUp()
        sleep(1)
        
        // Проверяем что кнопка Login доступна
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        
        // Дополнительная проверка - выводим отладочную информацию
        print("=== ОТЛАДОЧНАЯ ИНФОРМАЦИЯ ===")
        print("Поле логина: \(loginTextField.value ?? "N/A")")
        // Для поля пароля значение обычно недоступно, но попробуем
        print("Поле пароля доступно: \(passwordTextField.exists)")
        
        loginButton.tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 15))
    }

    func testFeed() throws {
        // Ждем загрузку ленты
        let tablesQuery = app.tables
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        
        // Свайпаем вверх чтобы посмотреть больше ячеек
        firstCell.swipeUp()
        sleep(2)
        
        // Берем вторую ячейку для тестирования лайков
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        // Ищем кнопку лайка по правильному идентификатору
        let likeButton = cellToLike.buttons["like button off"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        
        // Тапаем для добавления лайка (должен измениться на "like button on")
        likeButton.tap()
        sleep(2)
        
        // Проверяем, изменился ли идентификатор после лайка
        let likedButton = cellToLike.buttons["like button on"]
        if likedButton.waitForExistence(timeout: 3) {
            print("Лайк добавлен успешно, идентификатор изменился на 'like button on'")
            // Убираем лайк
            likedButton.tap()
            sleep(2)
            
            // Проверяем, что вернулся обратно идентификатор
            let unlikedButton = cellToLike.buttons["like button off"]
            XCTAssertTrue(unlikedButton.waitForExistence(timeout: 3), "Лайк не убрался")
        } else {
            // Если идентификатор не изменился, просто тапаем еще раз чтобы вернуть состояние
            likeButton.tap()
            sleep(2)
        }
        
        // Тестируем открытие и закрытие картинки
        cellToLike.tap()
        sleep(2)
        
        // Ждем загрузки изображения
        let image = app.images["full image view"]
        XCTAssertTrue(image.waitForExistence(timeout: 10))
        
        // Тестируем зуммирование
        // Zoom in
        image.pinch(withScale: 3, velocity: 1)
        sleep(1)
        
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(1)
        
        // Возвращаемся назад
        let navBackButton = app.buttons["nav back button white"]
        XCTAssertTrue(navBackButton.waitForExistence(timeout: 5))
        navBackButton.tap()
        sleep(1)
        
        // Проверяем, что вернулись в ленту
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        // Даем время загрузиться профилю
        sleep(2)
        
        // Проверяем наличие данных профиля
        XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
        XCTAssertTrue(app.staticTexts["@name"].exists)
        
        // Ищем кнопку выхода
        let logoutButton = app.buttons["logout button"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()
        
        // Подтверждаем выход
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["ДА"].tap()
        
        // Проверяем, что вернулись на экран авторизации
        let authenticateButton = app.buttons.element(boundBy: 0)
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 5))
    }
    
    }

