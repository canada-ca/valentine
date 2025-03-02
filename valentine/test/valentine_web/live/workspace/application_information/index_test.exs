defmodule ValentineWeb.WorkspaceLive.ApplicationInformation.IndexTest do
  use ValentineWeb.ConnCase

  import Valentine.ComposerFixtures

  setup do
    workspace = workspace_fixture()
    application_information = application_information_fixture(workspace_id: workspace.id)

    socket = %Phoenix.LiveView.Socket{
      assigns: %{
        __changed__: %{},
        touched: false,
        current_user: workspace.owner,
        live_action: nil,
        flash: %{},
        workspace_id: workspace.id
      }
    }

    %{
      application_information: application_information,
      socket: socket,
      workspace_id: workspace.id
    }
  end

  describe "mount/3" do
    test "mounts the component and assigns the correct assigns", %{
      workspace_id: workspace_id,
      application_information: application_information,
      socket: socket
    } do
      {:ok, socket} =
        ValentineWeb.WorkspaceLive.ApplicationInformation.Index.mount(
          %{"workspace_id" => workspace_id},
          nil,
          socket
        )

      assert socket.assigns.application_information == application_information
      assert socket.assigns.touched == false
      assert socket.assigns.workspace_id == workspace_id
    end
  end

  describe "handle_params/3 assigns the page title to :index action" do
    test "assigns the page title to 'Data flow diagram' when live_action is :index" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          __changed__: %{},
          live_action: :index,
          flash: %{},
          workspace_id: 1
        }
      }

      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.ApplicationInformation.Index.handle_params(nil, nil, socket)

      assert socket.assigns.page_title == "Application information"
    end
  end

  describe "handle_info/2" do
    test "handles local changes and broadcasts the change", %{
      application_information: application_information,
      socket: socket
    } do
      delta = %{"ops" => "some delta"}

      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.ApplicationInformation.Index.handle_info(
          {:quill_change, delta},
          socket
        )

      assert socket.assigns.touched == true

      assert [delta["ops"]] ==
               Valentine.Composer.ApplicationInformation.get_cache(
                 application_information.workspace_id
               )
    end

    test "handles remote changes", %{
      socket: socket
    } do
      delta = %{
        event: :quill_change,
        payload: %{"ops" => "some delta"}
      }

      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.ApplicationInformation.Index.handle_info(
          delta,
          socket
        )

      assert socket.assigns.touched == true

      assert socket.private == %{
               live_temp: %{
                 push_events: [["updateQuill", %{event: "text_change", payload: delta.payload}]]
               }
             }
    end

    test "handles remote save button clicked", %{
      application_information: application_information,
      socket: socket
    } do
      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.ApplicationInformation.Index.handle_info(
          %{event: :quill_saved},
          socket
        )

      assert socket.assigns.touched == false

      assert socket.private == %{
               live_temp: %{
                 push_events: [
                   [
                     "updateQuill",
                     %{
                       event: "blob_change",
                       payload: application_information.content
                     }
                   ]
                 ]
               }
             }
    end

    test "handles save button clicked", %{
      application_information: application_information,
      socket: socket
    } do
      content = "some content"

      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.ApplicationInformation.Index.handle_info(
          {:quill_save, content},
          socket
        )

      assert socket.assigns.touched == false

      assert Valentine.Composer.ApplicationInformation.get_cache(
               application_information.workspace_id
             ) == []
    end
  end
end
