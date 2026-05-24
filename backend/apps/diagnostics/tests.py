from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from .models import Sesion


class EliminarSesionViewTests(APITestCase):
    def setUp(self):
        User = get_user_model()
        self.user = User.objects.create_user(
            username='tester',
            email='tester@example.com',
            password='12345678',
        )
        self.other_user = User.objects.create_user(
            username='otro',
            email='otro@example.com',
            password='12345678',
        )
        self.sesion = Sesion.objects.create(
            usuario=self.user,
            tipo_prueba='Reflejos',
            puntaje_total=98.5,
            observaciones='Prueba de eliminación',
        )

    def test_eliminar_sesion_por_dueno(self):
        self.client.force_authenticate(user=self.user)
        url = reverse('eliminar_sesion', args=[self.sesion.id])

        response = self.client.delete(url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(Sesion.objects.filter(pk=self.sesion.id).exists())

    def test_no_puede_eliminar_sesion_de_otro_usuario(self):
        self.client.force_authenticate(user=self.other_user)
        url = reverse('eliminar_sesion', args=[self.sesion.id])

        response = self.client.delete(url)

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertTrue(Sesion.objects.filter(pk=self.sesion.id).exists())

    def test_eliminar_historial_completo(self):
        Sesion.objects.create(
            usuario=self.user,
            tipo_prueba='Reflejos',
            puntaje_total=88.0,
            observaciones='Otro registro',
        )
        self.client.force_authenticate(user=self.user)
        url = reverse('eliminar_historial')

        response = self.client.delete(url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(Sesion.objects.filter(usuario=self.user).count(), 0)
