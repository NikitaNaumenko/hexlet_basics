defmodule HexletBasics.Email do
  use Bamboo.Phoenix, view: HexletBasicsWeb.EmailView
  import HexletBasicsWeb.Gettext
  alias HexletBasicsWeb.Endpoint

  defp base_email(email_address, subject, conn) do
    new_email()
    |> to(email_address)
    |> from({"Code Basics", sending_from(conn)})
    |> subject(subject)
    |> put_html_layout({HexletBasicsWeb.LayoutView, "email.html"})
  end

  def confirmation_html_email(conn, user, url) do
    subject = gettext("Confirm registration")
    %{assigns: %{locale: locale_from_conn}} = conn

    locale = user.locale || locale_from_conn
    email_address = user.email

    email_address
    |>base_email(subject, conn)
    |> render(
      "user/confirmation.#{locale}.html",
      confirmation_url: url,
      subject: subject
    )
  end

  def reset_password_html_email(conn, user, url) do
    subject = gettext("Reset password")
    %{assigns: %{locale: locale_from_conn}} = conn

    locale = user.locale || locale_from_conn
    email_address = user.email

    email_address
    |>base_email(subject, conn)
    |> render(
      "user/reset_password.#{locale}.html",
      reset_password_url: url,
      subject: subject
    )
  end

  defp sending_from(conn) do
    #TODO: переделать на один домен после деплоя
    # sending_domain = Endpoint.config(:url)[:host]
    # "noreply@#{sending_domain}"

    "noreply@#{conn.host}"
  end
end
