ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Valentine.Repo, :manual)

System.put_env("GOOGLE_CLIENT_ID", "")
System.put_env("GOOGLE_CLIENT_SECRET", "")
System.put_env("COGNITO_DOMAIN", "")
System.put_env("COGNITO_CLIENT_ID", "")
System.put_env("COGNITO_CLIENT_SECRET", "")
System.put_env("COGNITO_USER_POOL_ID", "")
System.put_env("COGNITO_AWS_REGION", "")
System.put_env("MICROSOFT_TENANT_ID", "")
System.put_env("MICROSOFT_CLIENT_ID", "")
System.put_env("MICROSOFT_CLIENT_SECRET", "")
