@require Blink begin

using Blink: Page, loadjs!, body!, Window

struct BlinkConnection <: WebIO.AbstractConnection
    page::Page
end

function Blink.body!(p::Page, x::Union{Node, Scope})
    wait(p)
    loadjs!(p, "/pkg/WebIO/webio/dist/bundle.js")
    loadjs!(p, "/pkg/WebIO/providers/blink_setup.js")

    conn = BlinkConnection(p)
    Blink.handle(p, "webio") do msg
        WebIO.dispatch(conn, msg)
    end

    body!(p, stringmime(MIME"text/html"(), x))
end

function Blink.body!(p::Window, x::Union{Node, Scope})
    body!(p.content, x)
end

function Base.send(b::BlinkConnection, data)
    Blink.msg(b.page, Dict(:type=>"webio", :data=>data))
end

Base.isopen(b::BlinkConnection) = Blink.active(b.page)

function WebIO.register_renderable(T::Type, ::Val{:blink})
    Blink.body!(p::Union{Window, Page}, x::T) =
        Blink.body!(p, WebIO.render(x))
end

WebIO.setup_provider(::Val{:blink}) = nothing  # blink setup has no side-effects
WebIO.setup(:blink)

end
