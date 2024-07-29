--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

-- Started on 2024-07-12 17:38:19

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 254 (class 1255 OID 33448)
-- Name: add_favorite(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.add_favorite(IN in_member_id integer, IN in_product_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

	IF NOT EXISTS (
		SELECT id FROM product
		WHERE id = in_product_id
	) THEN
		RAISE EXCEPTION 'There is no product with that ID.';
	ELSIF EXISTS (
		SELECT * FROM favorite
		WHERE product_id = in_product_id
		AND member_id = in_member_id
	) THEN
		RAISE EXCEPTION 'You have already favourited this product.';
    END IF;

    INSERT INTO favorite (member_id, product_id)
    VALUES (in_member_id, in_product_id);
END $$;


ALTER PROCEDURE public.add_favorite(IN in_member_id integer, IN in_product_id integer) OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 33537)
-- Name: compute_customer_lifetime_value(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.compute_customer_lifetime_value()
    LANGUAGE plpgsql
    AS $$
DECLARE
    member_rec RECORD;
    first_order_date DATE;
    last_order_date DATE;
    tot_revenue NUMERIC;
    order_count INTEGER;
    avg_purchase_value NUMERIC;
    customer_lifetime NUMERIC;
    purchase_frequency NUMERIC;
    customer_lifetime_value NUMERIC;
    retention_period NUMERIC := 2.0;
BEGIN

    PERFORM compute_running_total_spending();

    FOR member_rec IN 
        SELECT id FROM member
    LOOP
        SELECT 
            MIN(o.order_datetime), MAX(o.order_datetime), 
            COALESCE(SUM(soi.quantity * p.unit_price), 0), 
            COUNT(*)
        INTO 
            first_order_date, last_order_date, tot_revenue, order_count
        FROM 
            sale_order o
        JOIN 
            sale_order_item soi ON o.id = soi.sale_order_id
        JOIN 
            product p ON soi.product_id = p.id
        WHERE 
            o.member_id = member_rec.id 
            AND o.status = 'COMPLETED';

        
        IF order_count > 1 THEN
            avg_purchase_value := tot_revenue / order_count;
            customer_lifetime := (last_order_date - first_order_date) / 365.0;
            purchase_frequency := order_count / customer_lifetime;

            
            customer_lifetime_value := avg_purchase_value * purchase_frequency * retention_period;

            
            UPDATE member
            SET clv = customer_lifetime_value
            WHERE id = member_rec.id;
        END IF;
    END LOOP;
END;
$$;


ALTER PROCEDURE public.compute_customer_lifetime_value() OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 33538)
-- Name: compute_running_total_spending(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.compute_running_total_spending() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	active_last DATE := CURRENT_DATE - INTERVAL '6 months';
	BEGIN
		UPDATE member m
		SET running_total_spending = (
			SELECT COALESCE(SUM(p.unit_price * i.quantity), 0)
			FROM sale_order o
			JOIN sale_order_item i ON o.id = i.sale_order_id
			JOIN product p ON i.product_id = p.id
			WHERE o.member_id = m.id
				AND o.status = 'COMPLETED'
		)
		WHERE m.last_login_on >= active_last;

		UPDATE member m
		SET running_total_spending = NULL
		WHERE m.last_login_on < active_last;
	END;
$$;


ALTER FUNCTION public.compute_running_total_spending() OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 33403)
-- Name: create_review(integer, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.create_review(IN in_member_id integer, IN in_product_id integer, IN in_rating integer, IN in_review_text text)
    LANGUAGE plpgsql
    AS $$
BEGIN

	IF NOT EXISTS (
        SELECT *
        FROM sale_order o
		JOIN sale_order_item i
		ON i.sale_order_id = o.id
        WHERE o.member_id = in_member_id
          AND i.product_id = in_product_id
          AND o.status = 'COMPLETED'
    ) THEN
        RAISE EXCEPTION 'Please ensure that your order for this product is completed before you give a review.';
    END IF;
	
	IF (
		in_rating < 1 OR in_rating > 5
	) THEN
        RAISE EXCEPTION 'Please enter a rating of 1 to 5 only.';
    END IF;

    INSERT INTO review (member_id, product_id, rating, review_text)
    VALUES (in_member_id, in_product_id, in_rating, in_review_text);
END $$;


ALTER PROCEDURE public.create_review(IN in_member_id integer, IN in_product_id integer, IN in_rating integer, IN in_review_text text) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 33408)
-- Name: delete_review(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delete_review(IN in_review_id integer, IN in_member_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

	IF NOT EXISTS (
        SELECT *
        FROM review
        WHERE member_id = in_member_id
          AND id = in_review_id
    ) THEN
        RAISE EXCEPTION 'You can only delete your own review.';
    END IF;

    DELETE FROM review
    WHERE id = in_review_id;
END $$;


ALTER PROCEDURE public.delete_review(IN in_review_id integer, IN in_member_id integer) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 33429)
-- Name: get_age_group_spending(character, numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_age_group_spending(p_gender character, p_min_total_spending numeric, p_min_member_total_spending numeric) RETURNS TABLE(age_group text, total_spending numeric, num_of_members bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE
            WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 18 AND 29 THEN '18-29'
            WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 30 AND 39 THEN '30-39'
            WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 40 AND 49 THEN '40-49'
            WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 50 AND 59 THEN '50-59'
            ELSE '60+'
        END AS age_group,
        SUM(member_total_spending) AS total_spending,
        COUNT(*) AS num_of_members
    FROM (
        SELECT
            m.id,
            m.dob,
            m.gender,
            COALESCE(SUM(p.unit_price * i.quantity), 0) AS member_total_spending
        FROM member m
        JOIN sale_order o ON m.id = o.member_id
        JOIN sale_order_item i ON o.id = i.sale_order_id
        JOIN product p ON i.product_id = p.id
        WHERE m.id NOT IN (11, 12)
        GROUP BY m.id, m.dob, m.gender
    ) subquery
    WHERE (p_gender IS NULL OR gender = p_gender)
      AND (p_min_member_total_spending IS NULL OR member_total_spending >= p_min_member_total_spending)
    GROUP BY age_group
    HAVING (p_min_total_spending IS NULL OR SUM(member_total_spending) >= p_min_total_spending)
	ORDER BY age_group ASC;
END; 
$$;


ALTER FUNCTION public.get_age_group_spending(p_gender character, p_min_total_spending numeric, p_min_member_total_spending numeric) OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 33535)
-- Name: get_all_favorites(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_all_favorites(in_member_id integer) RETURNS TABLE(favorite_id integer, product_id integer, product_name character varying, description text, unit_price numeric, country character varying, product_type character varying, image_url character varying, favorite_date date)
    LANGUAGE plpgsql
    AS $$
BEGIN

	IF NOT EXISTS (
		SELECT * FROM favorite
		WHERE member_id = in_member_id
	) THEN
		RAISE EXCEPTION 'You have not favorited any product.';
	END IF;

    RETURN QUERY
    SELECT f.id, p.id, p.name, p.description, p.unit_price, p.country, p.product_type, p.image_url, f.favorite_date
    FROM favorite f
	JOIN product p
	ON p.id = f.product_id
    WHERE f.member_id = in_member_id;
END $$;


ALTER FUNCTION public.get_all_favorites(in_member_id integer) OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 33464)
-- Name: get_all_products(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_all_products() RETURNS TABLE(product_id integer, name character varying, description text, unit_price numeric, country character varying, product_type character varying, image_url character varying, manufactured_on timestamp without time zone, num_of_favorites bigint, favorite_volume text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    avg_favorites NUMERIC;
BEGIN
    -- Calculate the average number of favorites
    SELECT AVG(fav_count) INTO avg_favorites
    FROM (
        SELECT COUNT(f.id) AS fav_count
        FROM product p
        LEFT JOIN favorite f ON f.product_id = p.id
        GROUP BY p.id
    ) subquery;

    RETURN QUERY
    SELECT 
		p.id,
        p.name,
        p.description,
        p.unit_price, 
        p.country,
        p.product_type,
        p.image_url,
		p.manufactured_on,
        COUNT(f.id) AS num_of_favorites,
        CASE 
            WHEN COUNT(f.id) > avg_favorites THEN 'Highly favorited'
			WHEN (COUNT(f.id) < avg_favorites AND COUNT(f.id) > 0) THEN 'Lowly favorited'
            ELSE 'No favorites'
        END AS favorite_volume
    FROM product p
    LEFT JOIN favorite f ON f.product_id = p.id
    GROUP BY p.id;
END $$;


ALTER FUNCTION public.get_all_products() OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 33406)
-- Name: get_all_reviews(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_all_reviews(in_member_id integer) RETURNS TABLE(review_id integer, product_name character varying, rating integer, review_text text, review_date date)
    LANGUAGE plpgsql
    AS $$
BEGIN

	IF NOT EXISTS (
		SELECT * FROM review
		WHERE member_id = in_member_id
	) THEN
		RAISE EXCEPTION 'You have no reviews.';
	END IF;

    RETURN QUERY
    SELECT r.id, p.name, r.rating, r.review_text, r.review_date
    FROM review r
	JOIN product p
	ON p.id = r.product_id
    WHERE r.member_id = in_member_id;
END $$;


ALTER FUNCTION public.get_all_reviews(in_member_id integer) OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 33534)
-- Name: get_product(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_product(in_product_id integer) RETURNS TABLE(product_id integer, name character varying, description text, unit_price numeric, country character varying, product_type character varying, image_url character varying, manufactured_on timestamp without time zone, num_of_favorites bigint, favorite_volume text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    avg_favorites NUMERIC;
BEGIN
    -- Calculate the average number of favorites
    SELECT AVG(fav_count) INTO avg_favorites
    FROM (
        SELECT COUNT(f.id) AS fav_count
        FROM product p
        LEFT JOIN favorite f ON f.product_id = p.id
        GROUP BY p.id
    ) subquery;

    RETURN QUERY
    SELECT 
		p.id,
        p.name,
        p.description,
        p.unit_price, 
        p.country,
        p.product_type,
        p.image_url,
		p.manufactured_on,
        COUNT(f.id) AS num_of_favorites,
        CASE 
            WHEN COUNT(f.id) > avg_favorites THEN 'Highly favorited'
			WHEN (COUNT(f.id) < avg_favorites AND COUNT(f.id) > 0) THEN 'Lowly favorited'
            ELSE 'No favorites'
        END AS favorite_volume
    FROM product p
    LEFT JOIN favorite f ON f.product_id = p.id
	WHERE p.id = in_product_id
    GROUP BY p.id;
END $$;


ALTER FUNCTION public.get_product(in_product_id integer) OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 33457)
-- Name: get_products_by_favorites(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_products_by_favorites(sort text) RETURNS TABLE(product_id integer, product_name character varying, unit_price numeric, product_type character varying, num_of_favorites bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    query TEXT;
BEGIN
    query := 'SELECT 
                p.id AS product_id, 
                p.name AS product_name, 
                p.unit_price, 
                p.product_type,
                COALESCE(COUNT(f.id), 0) AS num_of_favorites
              FROM product p
              LEFT JOIN favorite f ON f.product_id = p.id
              GROUP BY p.id ';

    IF sort = 'fav_asc' THEN
        query := query || 'ORDER BY num_of_favorites ASC, p.id ASC';
    ELSIF sort = 'fav_desc' THEN
        query := query || 'ORDER BY num_of_favorites DESC, p.id ASC';
    ELSE
        query := query || 'ORDER BY p.id ASC';
    END IF;

    RETURN QUERY EXECUTE query;
END $$;


ALTER FUNCTION public.get_products_by_favorites(sort text) OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 33533)
-- Name: get_review(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_review(in_review_id integer, in_member_id integer) RETURNS TABLE(review_id integer, product_name character varying, rating integer, review_text text, review_date date)
    LANGUAGE plpgsql
    AS $$
BEGIN

	IF EXISTS (
		SELECT r.* FROM review r
		WHERE r.id = in_review_id
	) THEN
		IF NOT EXISTS (
			SELECT r.* FROM review r
			WHERE r.member_id = in_member_id
			AND r.id = in_review_id
		) THEN
			RAISE EXCEPTION 'You did not make this review.';
		END IF;
	ELSE RAISE EXCEPTION 'This review does not exist.';
	END IF;

    RETURN QUERY
    SELECT r.id, p.name, r.rating, r.review_text, r.review_date
    FROM review r
	JOIN product p
	ON p.id = r.product_id
    WHERE r.member_id = in_member_id
	AND r.id = in_review_id;
END $$;


ALTER FUNCTION public.get_review(in_review_id integer, in_member_id integer) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 33452)
-- Name: remove_favorite_item(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.remove_favorite_item(IN in_favorite_id integer, IN in_member_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

	IF NOT EXISTS (
        SELECT *
        FROM favorite
        WHERE member_id = in_member_id
          AND id = in_favorite_id
    ) THEN
        RAISE EXCEPTION 'You can only remove your own favorite item.';
    END IF;

    DELETE FROM favorite
    WHERE id = in_favorite_id;
END $$;


ALTER PROCEDURE public.remove_favorite_item(IN in_favorite_id integer, IN in_member_id integer) OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 33410)
-- Name: update_review(integer, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_review(IN in_review_id integer, IN in_member_id integer, IN new_rating integer, IN new_review_text text)
    LANGUAGE plpgsql
    AS $$
BEGIN

	IF NOT EXISTS (
        SELECT *
        FROM review
        WHERE member_id = in_member_id
          AND id = in_review_id
    ) THEN
        RAISE EXCEPTION 'You can only modify your own review.';
    END IF;
	
	IF (
	new_rating IS NULL
	) THEN
        RAISE EXCEPTION 'Please choose a rating.';
    END IF;
	
	UPDATE review
    SET rating = new_rating,
        review_text = new_review_text
     WHERE id = in_review_id;
END $$;


ALTER PROCEDURE public.update_review(IN in_review_id integer, IN in_member_id integer, IN new_rating integer, IN new_review_text text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 227 (class 1259 OID 33507)
-- Name: avg_favorites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.avg_favorites (
    avg numeric
);


ALTER TABLE public.avg_favorites OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 33513)
-- Name: favorite; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.favorite (
    id integer NOT NULL,
    member_id integer NOT NULL,
    product_id integer NOT NULL,
    favorite_date date DEFAULT CURRENT_DATE NOT NULL
);


ALTER TABLE public.favorite OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 33512)
-- Name: favorite_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.favorite_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.favorite_id_seq OWNER TO postgres;

--
-- TOC entry 4923 (class 0 OID 0)
-- Dependencies: 228
-- Name: favorite_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.favorite_id_seq OWNED BY public.favorite.id;


--
-- TOC entry 215 (class 1259 OID 33060)
-- Name: member; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.member (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(50) NOT NULL,
    dob date NOT NULL,
    password character varying(255) NOT NULL,
    role integer NOT NULL,
    gender character(1) NOT NULL,
    last_login_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    clv numeric(10,3),
    running_total_spending numeric(10,3)
);


ALTER TABLE public.member OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 33064)
-- Name: member_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.member_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.member_id_seq OWNER TO postgres;

--
-- TOC entry 4924 (class 0 OID 0)
-- Dependencies: 216
-- Name: member_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.member_id_seq OWNED BY public.member.id;


--
-- TOC entry 217 (class 1259 OID 33065)
-- Name: member_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.member_role (
    id integer NOT NULL,
    name character varying(25)
);


ALTER TABLE public.member_role OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 33068)
-- Name: member_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.member_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.member_role_id_seq OWNER TO postgres;

--
-- TOC entry 4925 (class 0 OID 0)
-- Dependencies: 218
-- Name: member_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.member_role_id_seq OWNED BY public.member_role.id;


--
-- TOC entry 219 (class 1259 OID 33069)
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    id integer NOT NULL,
    name character varying(255),
    description text,
    unit_price numeric NOT NULL,
    stock_quantity numeric DEFAULT 0 NOT NULL,
    country character varying(100),
    product_type character varying(50),
    image_url character varying(255) DEFAULT '/images/product.png'::character varying,
    manufactured_on timestamp without time zone
);


ALTER TABLE public.product OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 33076)
-- Name: product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_id_seq OWNER TO postgres;

--
-- TOC entry 4926 (class 0 OID 0)
-- Dependencies: 220
-- Name: product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;


--
-- TOC entry 226 (class 1259 OID 33469)
-- Name: review; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.review (
    id integer NOT NULL,
    member_id integer NOT NULL,
    product_id integer NOT NULL,
    rating integer NOT NULL,
    review_text text,
    review_date date DEFAULT CURRENT_DATE NOT NULL,
    CONSTRAINT review_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.review OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 33468)
-- Name: review_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.review_id_seq OWNER TO postgres;

--
-- TOC entry 4927 (class 0 OID 0)
-- Dependencies: 225
-- Name: review_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.review_id_seq OWNED BY public.review.id;


--
-- TOC entry 221 (class 1259 OID 33077)
-- Name: sale_order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sale_order (
    id integer NOT NULL,
    member_id integer,
    order_datetime timestamp without time zone NOT NULL,
    status character varying(10)
);


ALTER TABLE public.sale_order OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 33080)
-- Name: sale_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sale_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sale_order_id_seq OWNER TO postgres;

--
-- TOC entry 4928 (class 0 OID 0)
-- Dependencies: 222
-- Name: sale_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sale_order_id_seq OWNED BY public.sale_order.id;


--
-- TOC entry 223 (class 1259 OID 33081)
-- Name: sale_order_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sale_order_item (
    id integer NOT NULL,
    sale_order_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity numeric NOT NULL
);


ALTER TABLE public.sale_order_item OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 33086)
-- Name: sale_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sale_order_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sale_order_item_id_seq OWNER TO postgres;

--
-- TOC entry 4929 (class 0 OID 0)
-- Dependencies: 224
-- Name: sale_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sale_order_item_id_seq OWNED BY public.sale_order_item.id;


--
-- TOC entry 4746 (class 2604 OID 33516)
-- Name: favorite id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorite ALTER COLUMN id SET DEFAULT nextval('public.favorite_id_seq'::regclass);


--
-- TOC entry 4736 (class 2604 OID 33087)
-- Name: member id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member ALTER COLUMN id SET DEFAULT nextval('public.member_id_seq'::regclass);


--
-- TOC entry 4738 (class 2604 OID 33088)
-- Name: member_role id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member_role ALTER COLUMN id SET DEFAULT nextval('public.member_role_id_seq'::regclass);


--
-- TOC entry 4739 (class 2604 OID 33089)
-- Name: product id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);


--
-- TOC entry 4744 (class 2604 OID 33472)
-- Name: review id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.review ALTER COLUMN id SET DEFAULT nextval('public.review_id_seq'::regclass);


--
-- TOC entry 4742 (class 2604 OID 33090)
-- Name: sale_order id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_order ALTER COLUMN id SET DEFAULT nextval('public.sale_order_id_seq'::regclass);


--
-- TOC entry 4743 (class 2604 OID 33091)
-- Name: sale_order_item id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_order_item ALTER COLUMN id SET DEFAULT nextval('public.sale_order_item_id_seq'::regclass);


--
-- TOC entry 4766 (class 2606 OID 33519)
-- Name: favorite favorite_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorite
    ADD CONSTRAINT favorite_pkey PRIMARY KEY (member_id, product_id);


--
-- TOC entry 4750 (class 2606 OID 33093)
-- Name: member member_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT member_email_key UNIQUE (email);


--
-- TOC entry 4752 (class 2606 OID 33095)
-- Name: member member_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT member_pkey PRIMARY KEY (id);


--
-- TOC entry 4756 (class 2606 OID 33097)
-- Name: member_role member_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member_role
    ADD CONSTRAINT member_role_pkey PRIMARY KEY (id);


--
-- TOC entry 4754 (class 2606 OID 33099)
-- Name: member member_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT member_username_key UNIQUE (username);


--
-- TOC entry 4758 (class 2606 OID 33101)
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- TOC entry 4764 (class 2606 OID 33478)
-- Name: review review_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_pkey PRIMARY KEY (member_id, product_id);


--
-- TOC entry 4762 (class 2606 OID 33103)
-- Name: sale_order_item sale_order_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_order_item
    ADD CONSTRAINT sale_order_item_pkey PRIMARY KEY (id);


--
-- TOC entry 4760 (class 2606 OID 33105)
-- Name: sale_order sale_order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_order
    ADD CONSTRAINT sale_order_pkey PRIMARY KEY (id);


--
-- TOC entry 4773 (class 2606 OID 33520)
-- Name: favorite favorite_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorite
    ADD CONSTRAINT favorite_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.member(id) ON DELETE CASCADE;


--
-- TOC entry 4774 (class 2606 OID 33525)
-- Name: favorite favorite_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorite
    ADD CONSTRAINT favorite_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


--
-- TOC entry 4767 (class 2606 OID 33106)
-- Name: member fk_member_role_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT fk_member_role_id FOREIGN KEY (role) REFERENCES public.member_role(id);


--
-- TOC entry 4769 (class 2606 OID 33111)
-- Name: sale_order_item fk_sale_order_item_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_order_item
    ADD CONSTRAINT fk_sale_order_item_product FOREIGN KEY (product_id) REFERENCES public.product(id);


--
-- TOC entry 4770 (class 2606 OID 33116)
-- Name: sale_order_item fk_sale_order_item_sale_order; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_order_item
    ADD CONSTRAINT fk_sale_order_item_sale_order FOREIGN KEY (sale_order_id) REFERENCES public.sale_order(id);


--
-- TOC entry 4768 (class 2606 OID 33121)
-- Name: sale_order fk_sale_order_member; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_order
    ADD CONSTRAINT fk_sale_order_member FOREIGN KEY (member_id) REFERENCES public.member(id);


--
-- TOC entry 4771 (class 2606 OID 33479)
-- Name: review review_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.member(id) ON DELETE CASCADE;


--
-- TOC entry 4772 (class 2606 OID 33484)
-- Name: review review_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


-- Completed on 2024-07-12 17:38:20

--
-- PostgreSQL database dump complete
--

