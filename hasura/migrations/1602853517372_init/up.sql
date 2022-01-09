CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;
CREATE TABLE public.competitions (
    id text NOT NULL,
    owner_id text NOT NULL,
    public boolean DEFAULT FALSE NOT NULL,
    description_en text,
    description_ja text,
    open_at timestamp with time zone NOT NULL,
    close_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.environments (
    id integer NOT NULL,
    match_id integer NOT NULL,
    public boolean DEFAULT FALSE NOT NULL,
    key text NOT NULL,
    value jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE SEQUENCE public.environments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.environments_id_seq OWNED BY public.environments.id;
CREATE TABLE public.matches (
    id integer NOT NULL,
    competition_id text NOT NULL,
    name text NOT NULL,
    budget integer NOT NULL,
    problem_id text NOT NULL,
    indicator_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE SEQUENCE public.matches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.matches_id_seq OWNED BY public.matches.id;
CREATE TABLE public.indicators (
    id text NOT NULL,
    owner_id text NOT NULL,
    image text NOT NULL,
    public boolean DEFAULT FALSE NOT NULL,
    description_en text,
    description_ja text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.problems (
    id text NOT NULL,
    owner_id text NOT NULL,
    image text NOT NULL,
    public boolean DEFAULT FALSE NOT NULL,
    description_en text,
    description_ja text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.solutions (
    id integer NOT NULL,
    owner_id text NOT NULL,
    match_id integer NOT NULL,
    variable jsonb NOT NULL,
    objective jsonb,
    "constraint" jsonb,
    score jsonb,
    evaluation_error text,
    scoring_error text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    evaluation_started_at timestamp with time zone,
    evaluation_finished_at timestamp with time zone,
    scoring_started_at timestamp with time zone,
    scoring_finished_at timestamp with time zone
);
CREATE SEQUENCE public.solutions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.solutions_id_seq OWNED BY public.solutions.id;
CREATE VIEW public.progress AS
 SELECT solutions.owner_id AS user_id,
    solutions.match_id,
    matches.budget,
    count(solutions.id) AS submitted,
    (count(solutions.evaluation_started_at) - count(solutions.evaluation_finished_at)) AS evaluating,
    count(solutions.evaluation_finished_at) AS evaluated,
    count(solutions.evaluation_error) AS evaluation_error,
    (count(solutions.scoring_started_at) - count(solutions.scoring_finished_at)) AS scoring,
    count(solutions.scoring_finished_at) AS scored,
    count(solutions.scoring_error) AS scoring_error,
    jsonb_agg(solutions.score ORDER BY solutions.id) AS scores,
    min(solutions.created_at) AS created_at,
    max(solutions.updated_at) AS updated_at,
    max(solutions.evaluation_started_at) AS evaluation_started_at,
    max(solutions.evaluation_finished_at) AS evaluation_finished_at,
    max(solutions.scoring_started_at) AS scoring_started_at,
    max(solutions.scoring_finished_at) AS scoring_finished_at
   FROM (public.solutions
     JOIN public.matches ON ((solutions.match_id = matches.id)))
  GROUP BY solutions.owner_id, solutions.match_id, matches.budget;
CREATE TABLE public.users (
    id text NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
ALTER TABLE ONLY public.environments ALTER COLUMN id SET DEFAULT nextval('public.environments_id_seq'::regclass);
ALTER TABLE ONLY public.matches ALTER COLUMN id SET DEFAULT nextval('public.matches_id_seq'::regclass);
ALTER TABLE ONLY public.solutions ALTER COLUMN id SET DEFAULT nextval('public.solutions_id_seq'::regclass);
ALTER TABLE ONLY public.competitions
    ADD CONSTRAINT competitions_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.environments
    ADD CONSTRAINT environments_match_id_key_key UNIQUE (match_id, key);
ALTER TABLE ONLY public.environments
    ADD CONSTRAINT environments_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.indicators
    ADD CONSTRAINT indicators_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_competition_id_name_key UNIQUE (competition_id, name);
ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.problems
    ADD CONSTRAINT problems_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.solutions
    ADD CONSTRAINT solutions_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_name_key UNIQUE (name);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
CREATE TRIGGER set_public_competitions_updated_at BEFORE UPDATE ON public.competitions FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_competitions_updated_at ON public.competitions IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_environments_updated_at BEFORE UPDATE ON public.environments FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_environments_updated_at ON public.environments IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_indicators_updated_at BEFORE UPDATE ON public.indicators FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_indicators_updated_at ON public.indicators IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_matches_updated_at BEFORE UPDATE ON public.matches FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_matches_updated_at ON public.matches IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_problems_updated_at BEFORE UPDATE ON public.problems FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_problems_updated_at ON public.problems IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_solutions_updated_at BEFORE UPDATE ON public.solutions FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_solutions_updated_at ON public.solutions IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_users_updated_at ON public.users IS 'trigger to set value of column "updated_at" to current timestamp on row update';
ALTER TABLE ONLY public.competitions
    ADD CONSTRAINT competitions_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.environments
    ADD CONSTRAINT environments_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.indicators
    ADD CONSTRAINT indicators_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_competition_id_fkey FOREIGN KEY (competition_id) REFERENCES public.competitions(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_indicator_id_fkey FOREIGN KEY (indicator_id) REFERENCES public.indicators(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_problem_id_fkey FOREIGN KEY (problem_id) REFERENCES public.problems(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.problems
    ADD CONSTRAINT problems_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.solutions
    ADD CONSTRAINT solutions_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.solutions
    ADD CONSTRAINT solutions_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
