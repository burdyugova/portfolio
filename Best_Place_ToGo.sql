/* Моя база данных собирает информацию о публикациях в блогах путешественников и 
 задумана, чтобы давать рекомендации пользователям по популярным маршрутам
 */

DROP DATABASE if EXISTS best_place_togo;
CREATE DATABASE best_place_togo;
USE best_place_togo;

-- Таблица, в которой будут храниться популярные travel-блоги

DROP TABLE if EXISTS bloggers;
CREATE TABLE bloggers (
	id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	name CHAR(15) UNIQUE,
	links TEXT AS (CONCAT('https://instagram.com/', name)),
	sex CHAR(10) DEFAULT NULL,
	followers INT UNSIGNED NOT NULL
);

-- Добавляем данные

INSERT INTO bloggers (name, followers, sex) VALUES 
	('_fenik_', '144000', 'female'),
	('vi66nya', '258000', 'female'),
	('hobopeeba', '686000', 'female'),
	('sonchicc', '295000', 'female'),
	('swaypaul', '221000', 'male'),
	('travelmaniac_ru', '168000', 'male'),
	('sergeysuxov', '717000', 'male'),
	('yana_leventseva', '855000', 'female'),
	('elivosk', '338000', 'male'),
	('mishka.travel', '150000', 'male');

-- Формируем ссылки

SELECT *, CONCAT('https://www.instagram.com/', name) as links FROM bloggers;

-- Таблица популярных публикаций

DROP TABLE if EXISTS publications;
CREATE TABLE publications (
	bloggers_id INT UNSIGNED NOT NULL,
	id_publications CHAR(40) PRIMARY KEY,
	publication_links TEXT AS (CONCAT('https://instagram.com/p/', id_publications)),
	text_publications TEXT,
	places VARCHAR(255),
	photo_id bigint UNSIGNED NULL,
	likes INT,
	created_at DATETIME DEFAULT NOW(),
	
	FOREIGN KEY (bloggers_id) REFERENCES bloggers(id) 
);

-- Наполняем данными

INSERT INTO publications (bloggers_id, id_publications, text_publications, places, photo_id, likes) VALUES 
	('1', 'B1bti_fHdLN', 'Этот пост о лучших террасах Барселоны, потому что не увидеть этот город сверху - не увидеть вообще!', 'Hotel Ohla Barcelona', '1', '6520'),
	('1', 'BxpniYSHz26', 'Закрытый ужин на крыше Ритца с лучшим видом на Красную площадь для дюжины лидеров мнений, и я среди приглашённых?', 'The Ritz-Carlton', '2', '8691'),
	('2', 'B1OnIBoIL4N', 'Люблю находить в нашей стране что-нибудь красивое, вот как эта мечеть в Татарстане, но не всё гладко с отечественным туризмом', 'Белая Мечеть', '3', '8631'),
	('7', 'B1gs3b3BbxK', 'Когда ваш друг-фотограф, так хотел поймать момент, что из фоток получилась гифка', 'Blue Lagoon Iceland', '4', '53517');

-- Хранилище фотографий популярных мест

DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL PRIMARY KEY,
    id_publications CHAR(40) NOT NULL,
    filename VARCHAR(255),
    size INT,
	metadata JSON,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX (id_publications),
    FOREIGN KEY (id_publications) REFERENCES publications(id_publications)
);

-- Добавляем фотографии, где ключ - это id публикации

INSERT INTO media (id_publications, filename, size) VALUES 
	('B1bti_fHdLN', 'Barcelona', '10'),
	('BxpniYSHz26', 'Moscow', '2'),
	('B1OnIBoIL4N', 'Kazan', '6'),
	('B1gs3b3BbxK', 'Iceland', '10');

-- Таблица мест, которые популярны среди блогеров

DROP TABLE if EXISTS places;
CREATE TABLE places (
	id_places SERIAL PRIMARY KEY,
	id_publications CHAR(40) NOT NULL,
	country CHAR(20),
	city CHAR(20),
	places VARCHAR(255) COMMENT 'Название достопримечательности',
	
	FOREIGN KEY (id_publications) REFERENCES publications(id_publications)
);

INSERT INTO places (id_publications, country, city, places) VALUES 
	('B1bti_fHdLN', 'Spain', 'Barcelona', 'Hotel Ohla Barcelona'),
	('BxpniYSHz26', 'Russia', 'Moscow', 'The Ritz-Carlton'),
	('B1OnIBoIL4N', 'Russia', 'Kazan', 'Белая мечеть'),
	('B1gs3b3BbxK', 'Iceland', 'Iceland', 'Blue Lagoon Iceland');

-- Профиль локации

DROP TABLE if EXISTS place_profiles;
CREATE TABLE place_profiles (
	id_places BIGINT UNSIGNED NOT NULL,
	places VARCHAR(255) COMMENT 'Название достопримечательности',
	descriptions VARCHAR(255),
	popular INT UNSIGNED,
	
	FOREIGN KEY (id_places) REFERENCES places(id_places)
);

INSERT INTO place_profiles (id_places, places, descriptions, popular) VALUES 
	('1', 'Hotel Ohla Barcelona', 'Красивый вид с балкона', '4'),
	('2', 'The Ritz-Carlton', 'Вид на Красную площадь', '5'),
	('3', 'Белая мечеть', 'Сложно добраться без машины', '4'),
	('4', 'Blue Lagoon Iceland', 'Великолепный вид', '5');

-- Как добраться

-- Близлежащие отели 

DROP TABLE if EXISTS hotels;
CREATE TABLE hotels (
	id_places BIGINT UNSIGNED NOT NULL,
	id_hotels SERIAL PRIMARY KEY,
	hotel_name VARCHAR(255) COMMENT 'Название отеля',
	distance_m INT UNSIGNED COMMENT 'Расстояние в метрах',
	rings INT UNSIGNED COMMENT 'Количество звезд',
	
	FOREIGN KEY (id_places) REFERENCES places(id_places)
);

INSERT INTO hotels (id_places, hotel_name, distance_m, rings) VALUES 
	('1', 'Hotel Ohla Barcelona', '0', '4'),
	('2', 'The Ritz-Carlton', '0', '5'),
	('3', 'Ривьера', '6000', '4'),
	('3', 'Крылья', '6370', '4'),
	('4', 'The Retreat at Blue Lagoon Iceland', '4200', '5');

-- Рестораны

DROP TABLE if EXISTS top_restaurants;
CREATE TABLE top_restaurants (
	id_places BIGINT UNSIGNED NOT NULL,
	id_restaurants SERIAL PRIMARY KEY,
	restaurant_name VARCHAR(255) COMMENT 'Название ресторана',
	distance_m INT UNSIGNED COMMENT 'Расстояние в метрах',
	
	FOREIGN KEY (id_places) REFERENCES places(id_places)
);

INSERT INTO top_restaurants (id_places, restaurant_name, distance_m) VALUES 
	('1', 'La Tartareria', '700'),
	('1', 'Anita Flow', '400'),
	('2', 'O2Lounge', '0'),
	('2', 'Армения', '300'),
	('2', 'McDonalds', '245'),
	('3', 'Чирэм', '600'),
	('3', 'Чайхона №1', '370'),
	('4', 'Parais', '1200');

-- Что еще посмотреть

DROP TABLE if EXISTS top_locations;
CREATE TABLE top_locations (
	id_places BIGINT UNSIGNED NOT NULL,
	id_locations SERIAL PRIMARY KEY,
	locations_name VARCHAR(255) COMMENT 'Название достопримечательности',
	distance_m INT UNSIGNED COMMENT 'Расстояние в метрах',
	
	FOREIGN KEY (id_places) REFERENCES places(id_places)
);

INSERT INTO top_locations (id_places, locations_name, distance_m) VALUES 
	('1', 'Sagrada Familia', '500'),
	('1', 'Montserrat', '4000'),
	('2', 'Красная площадь', '300'),
	('2', 'Большой театр', '300'),
	('2', 'Парк Горького', '2000');

-- Бюджет поездки

DROP TABLE if EXISTS budget;
CREATE TABLE budget (
	id_places BIGINT UNSIGNED NOT NULL,
	transport VARCHAR(255),
	budget INT UNSIGNED COMMENT 'Необходимый бюджет в рублях',
	
	FOREIGN KEY (id_places) REFERENCES places(id_places)
);

INSERT INTO budget (id_places, transport, budget) VALUES 
	('1', 'Самолет', '25000'),
	('2', 'Метро', '55'),
	('3', 'Поезд', '1800');

-- Анкета пользователя

DROP TABLE if EXISTS users;
CREATE TABLE users (
	id_users SERIAL PRIMARY KEY,
	name VARCHAR(255),
	bloggers_name CHAR(15),
	like_country VARCHAR(255),
	budget INT UNSIGNED COMMENT 'Бюджет на отпуск в рублях',
	
	FOREIGN KEY (bloggers_name) REFERENCES bloggers(name)
);

INSERT INTO users (name, bloggers_name, like_country, budget) VALUES 
	('Иван', 'vi66nya', 'Russia', '2000'),
	('Алена', '_fenik_', 'Italy', '500'),
	('Марьяна', '_fenik_', 'Spain', '30000');

-- Локации дешевле 2000 рублей (вложенный запрос)

SELECT id_places, 
(SELECT places FROM places WHERE budget.id_places = id_places) AS 'places', transport, budget
FROM budget
WHERE budget < 2000;

-- Где поесть и остановиться? (вложенный запрос)

SELECT
restaurant_name,
(SELECT hotel_name FROM hotels WHERE top_restaurants.id_places = id_places) AS 'Переночевать'
FROM top_restaurants WHERE id_places = 2;

-- Представления. Сортируем блогеров по количеству подписчиков

DROP VIEW if EXISTS popular;
CREATE VIEW popular AS SELECT * FROM bloggers ORDER BY followers DESC;
SELECT * FROM popular;

-- Представления. Сортируем рестораны по удаленности от Рица

DROP VIEW if EXISTS rest;
CREATE VIEW rest AS SELECT restaurant_name, distance_m FROM top_restaurants WHERE id_places = 2 ORDER BY distance_m ASC;
SELECT * FROM rest;

-- JOIN. Объединим популярные места и их профиль (тут стало понятно, что переменные можно было иначе назвать, но все работает)

(SELECT places.id_places, places.places 'Достопримечательность', places.city 'Город', place_profiles.descriptions 'Описание', place_profiles.popular 'Оценка'
FROM places
LEFT OUTER JOIN place_profiles ON place_profiles.id_places = places.id_places)
UNION
(SELECT places.id_places, places.places 'Достопримечательность', places.city 'Город', place_profiles.descriptions 'Описание', place_profiles.popular 'Оценка'
FROM places
RIGHT OUTER JOIN place_profiles ON place_profiles.id_places = places.id_places);

-- Хранимая функция. Дает рекомендацию в зависимости от введенной суммы

DELIMITER //

CREATE FUNCTION recommend ()
RETURNS TINYTEXT NOT DETERMINISTIC
BEGIN
	DECLARE hour INT;
	SET budget = VALUES;
	CASE
		WHEN budget BETWEEN 0 AND 54 THEN RETURN 'К сожалению, таких мест нет';
		WHEN budget BETWEEN 55 AND 1799 THEN RETURN 'Прогуляйтесь по Москве';
		WHEN budget BETWEEN 1800 AND 15000 THEN RETURN 'Посмотрите Белую мечеть в Казани';
		WHEN budget > 15000 THEN RETURN 'Барселона ждет вас';
	END CASE;
END//

SELECT recommend(55)//

-- Триггеры. Количество подписчиков у блогера не может быть пустым значением

DELIMITER //
CREATE TRIGGER vallidate_followers_insert BEFORE INSERT ON bloggers
FOR EACH ROW BEGIN
	IF NEW.followers IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Both name and desxription are NULL';
	END IF;
END//


