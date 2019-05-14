-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Хост: localhost
-- Время создания: Май 14 2019 г., 18:50
-- Версия сервера: 8.0.12
-- Версия PHP: 7.2.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `skilldrift`
--

-- --------------------------------------------------------

--
-- Структура таблицы `admins`
--

CREATE TABLE `admins` (
  `id` int(11) NOT NULL,
  `name` varchar(24) NOT NULL,
  `password` varchar(16) NOT NULL DEFAULT '-',
  `level` int(1) NOT NULL DEFAULT '0',
  `rankname` varchar(32) CHARACTER SET cp1251 COLLATE cp1251_general_ci NOT NULL DEFAULT 'New Admin'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

--
-- Дамп данных таблицы `admins`
--

INSERT INTO `admins` (`id`, `name`, `password`, `level`, `rankname`) VALUES
(1, 'd1maz.', '1234', 7, 'developer');

-- --------------------------------------------------------

--
-- Структура таблицы `houses`
--

CREATE TABLE `houses` (
  `id` int(11) NOT NULL,
  `price` int(11) NOT NULL DEFAULT '0',
  `interior` int(11) NOT NULL DEFAULT '0',
  `locked` int(11) NOT NULL DEFAULT '0',
  `owner` varchar(24) CHARACTER SET cp1251 COLLATE cp1251_general_ci NOT NULL DEFAULT '-',
  `enterpos` varchar(64) NOT NULL DEFAULT '0.0|0.0|0.0|0.0',
  `exitpos` varchar(64) NOT NULL DEFAULT '0.0|0.0|0.0|0.0',
  `comment` varchar(64) CHARACTER SET cp1251 COLLATE cp1251_general_ci NOT NULL DEFAULT '/changecomment'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

--
-- Дамп данных таблицы `houses`
--

INSERT INTO `houses` (`id`, `price`, `interior`, `locked`, `owner`, `enterpos`, `exitpos`, `comment`) VALUES
(1, 20000, 2, 0, '-', '-362.839|1110.74|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(2, 20000, 2, 0, '-', '-360.658|1141.8|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(3, 20000, 2, 0, '-', '-369.604|1169.49|20.272|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(4, 20000, 2, 0, '-', '-324.416|1165.67|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(5, 20000, 2, 0, '-', '-290.846|1176.64|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(6, 20000, 2, 0, '-', '-258.247|1168.82|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(7, 20000, 2, 0, '-', '-258.247|1151.04|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(8, 20000, 2, 0, '-', '-260.24|1120.11|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(9, 20000, 2, 0, '-', '-258.874|1083.07|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(10, 20000, 2, 0, '-', '-298.381|1115.67|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(11, 20000, 2, 0, '-', '-328.248|1118.88|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(12, 20000, 2, 0, '-', '-258.247|1043.9|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(13, 20000, 2, 0, '-', '-278.904|1003.07|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(14, 20000, 2, 0, '-', '-247.856|1001.08|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(15, 25000, 2, 0, '-', '-36.077|1115.67|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(16, 25000, 2, 0, '-', '-18.207|1115.67|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(17, 25000, 2, 0, '-', '-45.036|1081.08|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(18, 25000, 2, 0, '-', '12.818|1113.67|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(19, 25000, 2, 0, '-', '1.753|1076.14|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(20, 25000, 2, 0, '-', '-32.195|1038.66|20.94|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(21, 20000, 2, 0, 'd1maz.', '-715.887|1438.76|18.887|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(22, 20000, 2, 0, '-', '-690.068|1444.31|17.809|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment'),
(23, 20000, 2, 0, '-', '-636.377|1446.76|13.996|0.0', '2237.59|-1078.87|1049.02|0.0', '/changecomment');

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(24) NOT NULL,
  `password` varchar(32) NOT NULL,
  `cash` int(11) NOT NULL DEFAULT '0',
  `score` int(11) NOT NULL DEFAULT '0',
  `level` int(11) NOT NULL DEFAULT '1',
  `skin` int(11) NOT NULL DEFAULT '0',
  `pos` varchar(64) CHARACTER SET cp1251 COLLATE cp1251_general_ci NOT NULL DEFAULT '0.0|0.0|0.0|0.0',
  `togpm` int(11) NOT NULL DEFAULT '0',
  `timeingame` int(11) NOT NULL DEFAULT '0',
  `regip` varchar(16) NOT NULL,
  `regdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

--
-- Дамп данных таблицы `users`
--

INSERT INTO `users` (`id`, `name`, `password`, `cash`, `score`, `level`, `skin`, `pos`, `togpm`, `timeingame`, `regip`, `regdate`) VALUES
(1, 'd1maz.', '123456', 787330, 4310, 20, 1, '1461.542|1328.701|10.82|10.943', 0, 11255, '127.0.0.1', '2018-09-24 06:08:30');

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `houses`
--
ALTER TABLE `houses`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `admins`
--
ALTER TABLE `admins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT для таблицы `houses`
--
ALTER TABLE `houses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT для таблицы `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
