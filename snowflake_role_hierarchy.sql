WITH RECURSIVE grants_to_role AS (
    SELECT
        created_on,
        modified_on,
        privilege,
        granted_on,
        name,
        table_catalog,
        table_schema,
        granted_to,
        grantee_name,
        grant_option,
        granted_by,
        deleted_on,
        granted_by_role_type,
        '' AS inherited_from
    FROM snowflake.account_usage.grants_to_roles
    WHERE granted_on != 'ROLE' AND deleted_on IS NULL
    UNION ALL
    SELECT
        r.created_on,
        r.modified_on,
        r.privilege,
        r.granted_on,
        r.name,
        r.table_catalog,
        r.table_schema,
        r.granted_to,
        gr.grantee_name,
        gr.grant_option,
        r.granted_by || '-->' || gr.granted_by AS granted_by,
        gr.deleted_on,
        gr.granted_by_role_type,
        CASE
            WHEN r.inherited_from = '' THEN r.grantee_name
            ELSE CONCAT(r.inherited_from, '-->', gr.name)
        END AS inherited_from
    FROM snowflake.account_usage.grants_to_roles AS gr
    INNER JOIN grants_to_role AS r
        ON
            gr.granted_on = 'ROLE'
            AND gr.name = r.grantee_name
    WHERE
        gr.deleted_on IS NULL
        AND gr.privilege = 'USAGE'
)

select * from grants_to_roles;
