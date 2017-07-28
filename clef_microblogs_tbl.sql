SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;


CREATE TABLE IF NOT EXISTS `clef_microblogs_tbl` (
  `id` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  `from_user` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `from_user_id` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `iso_language_code` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `profile_image_url` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `wday` varchar(8) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` date DEFAULT NULL,
  `time_s` int(11) DEFAULT NULL,
  `time_ord` int(11) DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `iso_language_code` (`iso_language_code`),
  KEY `from_user` (`from_user`),
  KEY `from_user_id` (`from_user_id`),
  KEY `created_at` (`created_at`),
  KEY `wday` (`wday`),
  KEY `time_s` (`time_s`),
  KEY `source` (`source`),
  FULLTEXT KEY `content` (`content`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
