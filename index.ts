export interface Env {
  DB: D1Database;
  ADMIN_SECRET?: string;
  CORS_ORIGIN?: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname;

    if (request.method === 'GET' && path.startsWith('/api/i/')) {
      const slug = decodeURIComponent(path.replace('/api/i/', '').split('/')[0]);
      const guestToken = url.searchParams.get('g');
      const invitation = await env.DB.prepare(
        'SELECT * FROM invitations WHERE slug = ? AND published = 1'
      ).bind(slug).first();
      if (!invitation) return Response.json({ error: 'Not found' }, { status: 404 });

      const guest = guestToken
        ? await env.DB.prepare('SELECT * FROM guests WHERE invitation_id = ? AND guest_token = ?')
            .bind(invitation.id, guestToken).first()
        : null;

      const wishes = await env.DB.prepare(
        'SELECT * FROM guestbook_entries WHERE invitation_id = ? AND approved = 1 ORDER BY created_at DESC'
      ).bind(invitation.id).all();

      return Response.json({ invitation, guest, guestbook: wishes.results });
    }

    if (request.method === 'POST' && path === '/api/rsvp') {
      const body = await request.json() as any;
      await env.DB.prepare(
        'UPDATE guests SET rsvp_status = ?, attending_count = ?, dietary_notes = ?, updated_at = ? WHERE invitation_id = ? AND guest_token = ?'
      ).bind(body.rsvpStatus, body.attendingCount, body.dietaryNotes || '', new Date().toISOString(), body.invitationId, body.guestToken).run();
      return Response.json({ ok: true });
    }

    if (request.method === 'POST' && path === '/api/guestbook') {
      const body = await request.json() as any;
      const id = 'gb-' + crypto.randomUUID().slice(0, 8);
      await env.DB.prepare(
        'INSERT INTO guestbook_entries (id, invitation_id, author_name, relationship_en, relationship_ar, message, language, approved) VALUES (?, ?, ?, ?, ?, ?, ?, 1)'
      ).bind(id, body.invitationId, body.authorName, body.relationshipEn || '', body.relationshipAr || '', body.message, body.language || 'en').run();
      return Response.json({ id }, { status: 201 });
    }

    return Response.json({ error: 'Not found' }, { status: 404 });
  }
};